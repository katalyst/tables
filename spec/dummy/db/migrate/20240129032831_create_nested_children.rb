# frozen_string_literal: true

class CreateNestedChildren < ActiveRecord::Migration[7.1]
  def change
    create_table :nested_children do |t|
      t.string :name
      t.references :parent, null: false, foreign_key: true

      t.timestamps
    end
  end
end
