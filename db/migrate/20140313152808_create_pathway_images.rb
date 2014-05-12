class CreatePathwayImages < ActiveRecord::Migration
  def change
    create_table :pathway_images do |t|
      t.string     :xref
      t.integer    :img_height
      t.integer    :img_width
      t.attachment :background
      t.timestamps
    end
    add_index :pathway_images, :xref
  end
end
