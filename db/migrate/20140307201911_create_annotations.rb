class CreateAnnotations < ActiveRecord::Migration


##### DEPRICATED !!!

  def change
    #create_table :annotations do |t|
      #t.references 	:gene
      #t.references 	:annotation_collection
      #t.string     	:data_type
      #t.text		    :pt,   :limit=>262144    ##whatever is provided in the file as the data
    #end

    #add_index :annotations, :gene_id
    #add_index :annotations, :annotation_collection_id

  end
end
