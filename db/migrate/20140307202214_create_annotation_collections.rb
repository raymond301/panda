class CreateAnnotationCollections < ActiveRecord::Migration
  def change
    create_table :annotation_collections do |t|
      t.string      :name
      t.attachment  :icon
      t.integer  :originator_id
      t.timestamps
    end
    add_index :annotation_collections, :originator_id
  end
end
