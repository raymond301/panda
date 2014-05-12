class CreatePathwayCounts < ActiveRecord::Migration
def change
    create_table :pathway_counts do |t|
      t.string      :xref
      t.string      :countable_type
      t.integer     :countable_id
      t.decimal     :count, :default=>0, :precision=>8, :scale=>4
    end
    add_index :pathway_counts, :xref
    add_index :pathway_counts, :countable_id
  end
end
