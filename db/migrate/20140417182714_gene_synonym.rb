class GeneSynonym < ActiveRecord::Migration
  def change
    create_table :gene_synonyms do |t|
      t.references  :gene
      t.string      :define      ##type is reserved word
      t.string      :name
    end
    add_index :gene_synonyms, :name, :unique => true
  end
end
