class CreateEnrichments < ActiveRecord::Migration
  def change
    create_table :enrichments do |t|
      t.string      :name
      t.integer     :annotation_collection_id
      t.integer     :originator_id
      t.timestamps
    end
    add_index :enrichments, :originator_id
  end
end
