class Pathway < ActiveRecord::Base
  #has_attached_file :background, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  #validates_attachment_content_type :background, :content_type => /\Aimage\/.*\Z/

  ### Basically empty model...just a front to pathway_maps for cytoscape pathways.

  def self.xml_upload(file, name, xref, uid)
    doc = Nokogiri::XML(File.open(file.tempfile.path))

    ## Attempt to detect missing coordinate info
    if doc.css("graphics").empty?
      return "Nodes are missing Graphics/Coordinate information"
    end

    doc.css("node").each do |node|

      ## detect the type of xgmml format this is? "list" or "string"
      thisType = node.css("att").select{|n| n.attr("name")=~/^Gene/i}[0].attr("type")  rescue ''
      if thisType == "string"
        ### xgmml format type where single gene symbol attribute per node
        symbolAttempt = node.css("att").select{|n| n.attr("name")=~/Gene/i}.flatten[0].attr("value") rescue ''
        gn = Gene.find_by_symbol(symbolAttempt)
        if !gn.nil?

          myX,myX,myW,myH='0','0','10','10'
          if !node.css("graphics")[0].attr("x").nil?
            myX=node.css("graphics")[0].attr("x")
            myY=node.css("graphics")[0].attr("y")
            myW=node.css("graphics")[0].attr("w")
            myH=node.css("graphics")[0].attr("h")
          end

          pm = PathwayMap.new(
              name: name,
              xref: xref,
              source: 'Cytoscape',
              originator: uid,
              ent_name: node.attr("label"),
              ent_shape: node.css("graphics")[0].attr("type"),
              x: myX,
              y: myX,
              gene_symbol: gn.symbol,
              coords: myW+','+myH
          )
          pm.save!
        end

      elsif thisType == "list"
        ### xgmml format type where multiple possible gene symbols, attribute list per node
        arrayedAttributeNode = node.css("att").select{|n| n.attr("name")=~/^Gene/i}.first
        next if arrayedAttributeNode.children.size <= 1 rescue false
        allSymbolsAttempt = arrayedAttributeNode.children.map{|m| m.attr("value") }.compact

        allSymbolsAttempt.each do |symbAttempt|
          gn = Gene.find_by_symbol(symbAttempt)
          if !gn.nil?
            pm = PathwayMap.new(name: name, xref: xref,
                source: 'Cytoscape', originator: uid, ent_name: node.attr("label"),
                ent_shape: node.css("graphics")[0].attr("type"),
                x: node.css("graphics")[0].attr("x"), y: node.css("graphics")[0].attr("y"),
                gene_symbol: gn.symbol,
                coords: node.css("graphics")[0].attr("w")+','+node.css("graphics")[0].attr("h")
            )
            pm.save!
          end
        end

      end

    end

    map = PathwayMap.find_all_by_xref(xref)
    PathwayCount.create(xref: xref, countable_type: 'Gene', countable_id: 0, count: map.size )
    return nil
  end

end
