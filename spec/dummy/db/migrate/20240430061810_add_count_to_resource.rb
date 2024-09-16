# frozen_string_literal: true

class AddCountToResource < ActiveRecord::Migration[7.1]
  def change
    add_column :resources, :count, :integer
  end
end
