class AnnotationCollection < ActiveRecord::Base
  ## Include Paperclip requirements!
  has_attached_file :icon, :styles => {:tiny => "14x14>"}, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :icon, :content_type => /\Aimage\/.*\Z/
  has_and_belongs_to_many :groups

  def load_from_file(file)
    header = Array.new
    i=1
    hasBad = false
    exportableFilename = File.basename( file, ".*" )+'_'+ Time.now.to_s(:number)+'_'+self.originator_id.to_s+'.txt'
    badGenesFile = File.new( Rails.root.join('tmp' , exportableFilename), "w")
    goodGenes = Hash.new
    geneIdsMemLookup = Hash.new

    #### Uploaded File
    File.open(file, 'r').each_line do |line|
      line = AnnotationCollection.to_utf8(line)
      #puts line
      if line.match(/^#/) #will only keep last headerline
        header = line.chomp.strip.sub(/^#/, '').split("\t")
      end

      spLine = line.chomp.split("\t")

      ### Check if this gene has already been seen or not (prevent additional db call)
      if goodGenes.has_key?(spLine[0])
        goodGenes[spLine[0]].push(spLine)
      else
        g = Gene.find_by_symbol_or_synonym(spLine[0])
        if g.nil?
          ### Cannot Map this row Log and move on
          hasBad = true
          badGenesFile.write(line)
        else
          ### Found a match, store it!
          goodGenes[spLine[0]]=[spLine]
          geneIdsMemLookup[spLine[0]]=g.id
        end

      end

      i+=1
      if Rails.configuration.upload_limit && i >= 1000
        break
      end
    end

    goodGenes.each do |ele|
      table = AnnotationCollection.aoa2Table(ele[1],header)
      PathwayMap.create_by_annotation(gene: ele[0],annotation_collection_id: self.id, data: table )
    end
    geneIdsMemLookup.size


    ## if no bad genes, just delete, otherwise push up to sidebar! session? cookie? idk
    if !hasBad
      File.delete(badGenesFile)
      return nil
    else
      return 'tmp/'+exportableFilename
    end



  end


  def set_pathway_counts()
    queryCounts = AnnotationCollection.find_by_sql("SELECT xref, COUNT(DISTINCT(gene_symbol)) as cnt FROM pathway_maps WHERE annotation_collection_id = #{self.id} GROUP BY xref;")
    queryCounts.each do |q|
      PathwayCount.create(
          xref: q.xref,
          countable_type: 'AnnotationCollection',
          countable_id: self.id,
          count: q.cnt
      )
    end

    haveAnnot = queryCounts.map{|a|a.xref}
    allPathways = PathwayMap.select(:xref).uniq.map{|a|a.xref}
    (allPathways-haveAnnot).each do |q|
      PathwayCount.create(
          xref: q,
          countable_type: 'AnnotationCollection',
          countable_id: self.id,
          count: 0
      )
    end

  end




  def self.preview(file)
    header = Array.new
    previewLines = Array.new
    File.open(file, 'r').each_with_index do |line, i|
      if line.match(/^#/) #will only keep last headerline
        header = line.strip.sub(/^#/, '').split("\t")
      else
        previewLines.push(line.split("\t"))
      end
      if i > 3
        break
      end
    end

    return header, previewLines
  end



  private

  def self.aoa2Table(aoa, header)
      html='<table id="annot" class="table">'
      html+='<tr>'+header.map{|h| '<th>'+h+'</th>'}.join('')+'</tr>'
      aoa.each do |arr|
        html+='<tr>'+arr.map{|e| '<td>'+e+'</td>'}.join('')+'</tr>'
      end
      html+='</table>'
      return html
  end

  def self.to_utf8(str)
    str = str.force_encoding("UTF-8")
    return str if str.valid_encoding?
    str = str.force_encoding("BINARY")
    str.encode("UTF-8", invalid: :replace, undef: :replace)
  end

end
