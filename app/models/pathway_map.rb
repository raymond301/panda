class PathwayMap < ActiveRecord::Base
  belongs_to :pathway_image, :foreign_key => 'xref'
  CONN = ActiveRecord::Base.connection

  def self.pathway_counts
    #find_by_sql("SELECT name, xref, source, COUNT(gene_symbol) as gene_count, COUNT(annotation_collection_id) as annot_count FROM pathway_maps GROUP BY name, xref, source;")
    find_by_sql("SELECT name, xref, source FROM pathway_maps GROUP BY name, xref, source;")
  end

  def self.custom_pathway_counts(uid)
    find_by_sql("SELECT name, xref FROM pathway_maps WHERE source = 'Cytoscape' AND originator = #{uid} GROUP BY name, xref;")
  end

  def self.select_pathway_counts(str)
    q=str.split(",").map{|a| "'#{a}'"}.join(",")
    find_by_sql("SELECT name, xref, source FROM pathway_maps WHERE gene_symbol IN (#{q}) GROUP BY name, xref, source;")
  end

  def self.get_my_map(xref)
    find_by_sql("SELECT * FROM pathway_maps as pm LEFT OUTER JOIN annotation_collections as ac ON ac.id = pm.annotation_collection_id WHERE xref = '#{xref}' ORDER BY x, y;" )
  end

  def self.get_uniq_gene_counts
    find_by_sql("SELECT xref, COUNT(DISTINCT(gene_symbol)) AS count FROM pathway_maps GROUP BY xref;")
  end

  def self.global_gene_count
    find_by_sql("SELECT DISTINCT(gene_symbol) as count FROM pathway_maps;").count
  end

  def self.genes_per_annotation_per_pathway(id)
    find_by_sql("SELECT xref, COUNT(DISTINCT(gene_symbol)) as count FROM pathway_maps WHERE annotation_collection_id = #{id} GROUP BY xref;")
  end

  def self.uniq_gene_count_of_this_annotation(id)
    find_by_sql("SELECT DISTINCT(gene_symbol) as count FROM pathway_maps WHERE annotation_collection_id = #{id};").count
  end

  ### For pathways/index
  def self.get_custom_pathways
    find_by_sql("SELECT name, xref, originator FROM pathway_maps WHERE source='Cytoscape' GROUP BY name, xref, originator;")
  end

  def self.create_by_annotation(attr)
    # gene: ele[0],annotation_collection_id: self.id, data: table

    myMaps = PathwayMap.find(:all, :conditions => { :gene_symbol => attr[:gene], :pt => nil } )
    if myMaps.empty?
      return nil
    end

    collectInserts=Array.new
    myMaps.each do |m|
      duppedStr="'#{m.name}','#{m.source}','#{m.xref}','#{m.ent_url}','#{m.ent_name}','#{m.ent_shape}','#{m.x}','#{m.y}','#{m.gene_symbol}','#{m.coords}'"
      santable= ActiveRecord::Base::sanitize( attr[:data] )
      newStatement =  "(#{duppedStr},#{attr[:annotation_collection_id]},#{santable})"
      collectInserts.push( newStatement )
    end

    sql = "INSERT INTO pathway_maps (name,source,xref,ent_url,ent_name,ent_shape,x,y,gene_symbol,coords,annotation_collection_id,pt) VALUES #{  collectInserts.join(", ") }"
    CONN.execute sql

    #  newMap = mapObj.dup
    #  newMap.annotation_collection_id = attr[:annotation_collection_id]
    #  newMap.pt = attr[:data]
    # newMap.save!
    #end
  end


end

