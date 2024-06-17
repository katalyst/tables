class AddAttributesToParent < ActiveRecord::Migration[7.1]
  def change
    add_column :parents, :active, :boolean
    add_column :parents, :role, :integer, default: 0, null: false
  end
end
