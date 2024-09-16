# frozen_string_literal: true

class AddAttributesToPerson < ActiveRecord::Migration[7.1]
  def change
    add_column :people, :active, :boolean, default: false, null: false
  end
end
