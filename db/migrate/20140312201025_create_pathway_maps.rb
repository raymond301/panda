class CreatePathwayMaps < ActiveRecord::Migration
  def change
    create_table :pathway_maps do |t|
      ### Pathway ###
      t.string     :name
      t.string     :url
      t.string     :source
      t.string     :xref
      t.integer    :originator
    # t.attachment :background    ### Moved to a seperate model to reduce storage.

      ### Entities ###
      t.text        :ent_url
      t.string      :ent_name
      t.string      :ent_shape
      t.string      :x
      t.string      :y
      t.string      :gene_symbol
      t.text        :coords
      t.text		    :pt,   :limit=>262144    ##whatever is provided in the file as the data
      t.references 	:annotation_collection
    end
    add_index :pathway_maps, :xref
    add_index :pathway_maps, :originator
    add_index :pathway_maps, :annotation_collection_id
    add_index :pathway_maps, :gene_symbol
  end
end
