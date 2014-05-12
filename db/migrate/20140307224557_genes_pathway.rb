class GenesPathway < ActiveRecord::Migration

##### DEPRICATED !!!
##### DEPRICATED !!!
##### DEPRICATED !!!



  def change
    create_table :genes_pathways, :id => false do |t|
      t.references :pathway
      t.references :gene
    end

    add_index :genes_pathways, :pathway_id
    add_index :genes_pathways, :gene_id
  end
end
