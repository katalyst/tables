# frozen_string_literal: true

class AddCategoryToResources < ActiveRecord::Migration[7.1]
  def change
    add_column :resources, :category, :integer, default: 0, null: false
  end
end
