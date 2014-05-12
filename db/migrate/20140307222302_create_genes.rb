class CreateGenes < ActiveRecord::Migration
  def change
    create_table :genes do |t|
      t.string :symbol, :null=>false
      t.string :fullname
    end
    add_index :genes, :symbol, :unique => true
  end
end
