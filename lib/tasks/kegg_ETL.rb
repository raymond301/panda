require 'open-uri'
require 'nokogiri'
require 'yaml'
require 'bio'
require 'paperclip'

keggBASE="http://www.genome.jp/kegg/pathway.html"
numOfPathways=0


############ ETL KEGG #################
## rails runner lib/tasks/kegg_ETL.rb


#### Run out to web for KEGG pathways ####
page=Nokogiri::HTML(open(keggBASE).read)
allLinks=page.css('td a')


skipable=0
#### Loop over all links, follow only pathway links  
allLinks.each do |pwLink|


  ### Only interested in links that have pathway assoc.
  next if pwLink['href'] !~ /show_pathway/i
  next if pwLink['href'] =~ /map0\d+/i ### Skip kegg's aggragated maps of compounds
  nextLink="http://www.genome.jp#{pwLink['href']}" ## append base url

  skipable+=1
  if skipable < 35
    next
  end

  showPathway=Nokogiri::HTML(open(nextLink).read)

  ## Pathway Name
  puts pwLink.content
  puts pwLink['href']

  ## Looking for KEGG's source kgml file
  showPathway.css('a').each do |lnk|
    if lnk['href'] =~ /kgml/i || lnk.content =~ /kgml/i

      kgmlFile = Rails.root.join('public', 'tmpLoading', File.basename(lnk['href']))
      File.open(kgmlFile, 'wb') { |f| f.write(open(lnk['href']).read) }


      xml = File.read(kgmlFile)
      kgml = Bio::KEGG::KGML.new(xml)

      ## Skip Pathways that have no Genes
      ## Need to create a way to handle Orthologs/Ko Protiens
      if kgml.entries.keep_if { |g| g.category == "gene" }.size == 0
        puts "  No Genes in KGML"
        next
      end

      numOfPathways+=1

      if kgml.name.empty?
        raise kgml.inspect
      end

      pGeneList = Array.new
      kgml.entries.each do |e|
        if e.category == "gene"

          AcceptedGene = Array.new
          e.graphics[0].name.gsub("...", '').split(", ").each do |gname|
            gn = Gene.find_by_symbol(gname)
            if !gn.nil?
              AcceptedGene.push(gname)
            end
          end

          pGeneList.push(AcceptedGene)
          fullName = AcceptedGene.join(", ")

          AcceptedGene.each do |gName|

            pm = PathwayMap.new(name: pwLink.content, xref: kgml.name.gsub(":", '_'), url: pwLink['href'],
                source: 'KEGG', originator: 1, ent_url: e.link, ent_name: fullName,
                ent_shape: e.graphics[0].type, x: e.graphics[0].x, y: e.graphics[0].y,
                gene_symbol: gName,
                coords: e.graphics[0].width.to_s+','+e.graphics[0].height.to_s
            )
            pm.save!
          end


        end
      end

      PathwayCount.create(
          xref: kgml.name.gsub(":", '_'),
          countable_type: 'Gene',
          countable_id: 0, count: pGeneList.flatten.uniq.size
      )


      #### GRAB the associated image.
      imgFile=nil
      showPathway.xpath("//img/@src").each do |src|
        uri = URI.parse(keggBASE).merge(URI.parse(src)).to_s
        imgFile = Rails.root.join('app', 'assets', 'images', File.basename(uri))
        File.open(imgFile, 'wb') { |f| f.write(open(uri).read) }
      end
      openedImageHandle = File.open(imgFile, 'r')
      dim = Paperclip::Geometry.from_file(openedImageHandle)
      pi = PathwayImage.new(
          xref: kgml.name.gsub(":", '_'),
          img_height: dim.height,
          img_width: dim.width,
      )
      pi.background = openedImageHandle
      pi.save!

      ### remove temp kegg file:
      File.delete(kgmlFile)
      File.delete(imgFile)

    end
  end

  sleep 1 ## Don't hit KEGG server too hard.
  #if numOfPathways >= 6
  #  puts "Done... "+numOfPathways.to_s+" pathways"
  #  exit 0
  #end


end
  
  
  
  
  