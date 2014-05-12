class CreatePathways < ActiveRecord::Migration


  ##### DEPRICATED !!!



def change
    create_table :pathways do |t|
      t.string     :name
      t.string     :url
      t.string     :source
      t.string     :xref
      t.integer    :originator
      t.string     :file
      t.text     :gene_id_list
      t.attachment :background
    end
  end
end
