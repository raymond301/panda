require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'pp'


pharmBASE="http://www.pharmgkb.org"
pharmQuery="http://www.pharmgkb.org/search/browse.action?browseKey=pgkbPathways&returnType=ajax&tabType=PharmGKB Pathways"
numOfPathways=0

correction ={
    'HLAB' => 'HLA-B'
}

agent = Mechanize.new
allPathways = agent.get(pharmQuery)


allPathways.links.each do |pharmLink|
  next if pharmLink.href !~ /^\/pathway/

 # puts    pharmLink.href
  pName = pharmLink.href.sub("/pathway/", '')


  ### will be placed into yaml definition.
  puts "Connecting....#{pharmLink.text}"

  begin
    page=Nokogiri::HTML(open(pharmBASE+pharmLink.href).read)
  rescue
    if breakOnWebFailure
      puts "Host Failure:  #{pharmBASE+pharmLink.href}"
    else
      File.open('seed.log', 'a') { |f| f.write("#{line}:404 error\n #{page}") }
      puts "\tSkipping #{pharmLink.text}"
      next
    end
  end


  totalGeneCount=0
  page.css('#pathwayMap').css('area').each do |areaTag|
    #puts pName
    cleanedGene = areaTag['alt'].upcase.sub(/\*.+$/,'') rescue ''
    if correction.has_key?(cleanedGene)
      cleanedGene = correction[cleanedGene]
    end

    corners = areaTag['coords'].split(',')
    #w=corners[2].to_i - corners[0].to_i
    #h=corners[3].to_i - corners[1].to_i

    existGn = Gene.find_by_symbol( cleanedGene ) rescue nil
    if existGn.nil? && areaTag['onclick'] =~ /\/views\/pathway/
      multiGeneLink = pharmBASE+areaTag['onclick'].match(/\'(.+)\'/).captures[0] rescue nil
      begin
      subPage=Nokogiri::HTML(open(multiGeneLink).read).css('a')

      subPage.each do |lk|
        existSubGn = Gene.find_by_symbol( lk['text'].upcase ) rescue nil
        if !existSubGn.nil?
          totalGeneCount+=1
        pm = PathwayMap.new(name: pharmLink.text, xref: pName,
            url: pharmBASE+pharmLink.href,
            source: 'PharmGKB', originator: 1,
            ent_url: pharmBASE+lk['href'],
            ent_name: lk['text'].upcase,
            ent_shape: areaTag['shape'],
            x: (corners[0].to_i ), y: (corners[1].to_i ),
            gene_symbol: existSubGn.symbol,
            coords: areaTag['coords']
        )
        pm.save!
          end

      end

      rescue
        puts "\tCannot connect to: #{multiGeneLink}"
      end


    elsif !existGn.nil?
      totalGeneCount+=1
      pm = PathwayMap.new(name: pharmLink.text, xref: pName,
          url: pharmBASE+pharmLink.href,
          source: 'PharmGKB', originator: 1,
          ent_url: '',
          ent_name: cleanedGene,
          ent_shape: areaTag['shape'],
          x: (corners[0].to_i + 23 ), y: (corners[1].to_i + 12),
          gene_symbol: existGn.symbol,
          coords: areaTag['coords']
      )
      pm.save!

    end

  end

  ## Create Pathway Record
  PathwayCount.create(xref: pName, countable_type: 'Gene', countable_id: 0, count: totalGeneCount)

  imgFile = Rails.root.join('app', 'assets', 'images', "#{pName}.gif")
  File.open(imgFile, 'wb') { |f| f.write(open("#{pharmBASE}/views/pathway/#{pName}.png").read) }
  openedImageHandle = File.open(imgFile, 'r')
  dim = Paperclip::Geometry.from_file(openedImageHandle)
  pi = PathwayImage.new(
      xref: pName,
      img_height: dim.height,
      img_width: dim.width,
  )
  pi.background = openedImageHandle
  pi.save!



  sleep 1
  numOfPathways+=1

  #if numOfPathways >= 7
  #  exit 0
  #end

  File.delete(imgFile)

end


#### area map RECT = x1,y1,x2,y2  => left, top, right, bottom
## kegg coords = w,h