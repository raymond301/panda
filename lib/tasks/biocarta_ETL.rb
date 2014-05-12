require 'open-uri'
require 'nokogiri'
require 'mechanize'

biocartaBASE="http://www.biocarta.com"
breakOnWebFailure=true
skipIfyamlExists=Hash.new
numOfPathways=0
#### Library Variable, for repeated gene lookup
reservedNonHTMLlookup=Hash.new
if File.exist?('biocartaLookUp.lib')
  reservedNonHTMLlookup=YAML::load_file('biocartaLookUp.lib') rescue {}
end


def optimalPair(coord_str)
  coords=coord_str.split(",")
  minX=99999
  fellowY=0
  (0..coords.length-1).step(2) do |n|
    if minX > coords[n].to_i
      minX=coords[n].to_i
      fellowY=coords[n+1].to_i
    end
  end
  ### return x, y of upper left most pair of poly
  return minX, fellowY
end


def convertPolygon(str)
  arr = str.split(",")
  outStr = String.new
  arr.each_with_index do |e, i|
    if i%2==0
      outStr += "L#{e}"
    else
      outStr += ",#{e} "
    end
  end
  outStr.sub!(/^L/, 'M')
  return outStr+'Z'
end

##  rails runner lib/tasks/fetchBiocarta.rb
page=Nokogiri::HTML(open(biocartaBASE+'/genes/allPathways.asp').read)
allLinks=page.css('a')

allLinks.each do |pwLink|
  next if pwLink['href'] !~ /pathfiles/i

  pName = pwLink['href'].split(/\//)[2].gsub(".asp", '')
  #bcPathway=Rails.root.join('public', 'pathways', "#{pName}.yml")

  if skipIfyamlExists.has_key?(pName)
    puts "Skip: Already have #{pName}"
    next
  else
    skipIfyamlExists[pName]=0
  end

  if pName =~ /^m_/
    puts "Skip: Mouse Pathway #{pName}"
    next
  end



  ### will be placed into yaml definition.
  puts "Connecting....#{pwLink['href']}"

  begin
    page=Nokogiri::HTML(open(biocartaBASE+"#{pwLink['href']}").read)
      #pathwayObject["PathwayURL"]=biocartaBASE+"#{pwLink['href']}"
  rescue
    if breakOnWebFailure
      puts "Host Failure:  #{biocartaBASE} #{pwLink['href']}"
      #exit 1
    else
      File.open('seed.log', 'a') { |f| f.write("#{line}:404 error\n #{page}") }
      puts "\tSkipping #{pName}"
      next
    end
  end


  ## Create ruby object of FULL pathway info, to be saved.
  totalGenes = Array.new
  pathwayName=page.css('b').children[0].text.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).gsub(/[\n\r\t]/, '')

  page.css('map')[-1].css('area').each do |ele|
    koGroup=Hash.new
    ele.attributes.values.map { |e| koGroup[e.name]=e.value }

    agent = Mechanize.new
    agent.follow_meta_refresh = true

    ### Search through links to only those that link to protein allocation
    next if ele['href'] =~ /http\:\/\/www\.ncbi\.nlm\.nih\.gov\/entrez\/query\.fcgi/
    next if ele['href'] =~ /^#/
    next if ele['href'] =~ /^JavaScript/
    next if ele['href'] =~ /\/pathfiles\/SavePathwayLink\.asp\?/
    next if ele['href'] =~ /^mailto:/

    #puts ele['href']
    pu = ele['href'][/\(.*?\)/].gsub(/[()']/, "")
    next if pu !~ /\.htm$/

    if reservedNonHTMLlookup.has_key?(pu)
      gn = reservedNonHTMLlookup[pu]
    else
      puts "\t>#{pu}"
      begin
        geneCardLink = agent.get(pu).link_with(:text => "GeneCards")
        gn = geneCardLink.uri.to_s.match(/\?gene=(.+)',/).captures[0]
        if !gn.empty?
          reservedNonHTMLlookup[pu]=gn
        end
      rescue
        puts "\tCannot connect to: #{pu}"
        gn=pu.split("/")[-1].split(".")[0].upcase
        puts "\tAttempt from raw: #{gn}"

      end
    end


    #puts "\t-> #{gn}"
    cleanedGN = gn.upcase.sub(/^M_/, '')
    existGn = Gene.find_by_symbol(cleanedGN) rescue nil
    if !existGn.nil?
      if !reservedNonHTMLlookup.has_key?(pu)
        reservedNonHTMLlookup[pu] = gn
      end

      totalGenes.push(existGn.id)
      x_pos, y_pos = optimalPair(koGroup["coords"])
      raphaelString = convertPolygon(koGroup["coords"])

      pm = PathwayMap.new(name: pathwayName, xref: pName,
          url: biocartaBASE+"#{pwLink['href']}",
          source: 'Biocarta', originator: 1,
          ent_url: koGroup["link"],
          ent_name: cleanedGN,
          ent_shape: koGroup["shape"],
          x: x_pos, y: y_pos,
          gene_symbol: cleanedGN,
          coords: raphaelString
      )
      pm.save!

    else
      puts "\t\t=> Gene Not Found! #{cleanedGN}"
    end

  end


  ## Create Pathway Record
  PathwayCount.create(xref: pName, countable_type: 'Gene', countable_id: 0, count: totalGenes.uniq.size)


  imgFile = Rails.root.join('app', 'assets', 'images', "#{pName}.gif")
  File.open(imgFile, 'wb') { |f| f.write(open("http://www.biocarta.com//pathfiles/#{pName}.gif").read) }
  openedImageHandle = File.open(imgFile, 'r')
  dim = Paperclip::Geometry.from_file(openedImageHandle)
  pi = PathwayImage.new(
      xref: pName,
      img_height: dim.height,
      img_width: dim.width,
  )
  pi.background = openedImageHandle
  pi.save!


  numOfPathways+=1
  #if numOfPathways >= 8
  #  exit 0
  #end


  output = File.new('biocartaLookUp.lib', 'w')
  output.puts YAML.dump(reservedNonHTMLlookup)
  output.close
  File.delete(imgFile)


end
### delete images in assest dir?


