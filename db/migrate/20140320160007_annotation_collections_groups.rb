class AnnotationCollectionsGroups < ActiveRecord::Migration
  def change
    create_table :annotation_collections_groups, :id => false do |t|
      t.references :group
      t.references :annotation_collection
    end
  end
end
