class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string      :name, :default => 'MyGroup'
      t.string      :visibility
      t.string      :description
      t.string      :aggregated_type
      t.integer     :originator
      t.string      :username
      t.timestamps
    end
  end
end
