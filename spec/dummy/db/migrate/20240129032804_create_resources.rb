# frozen_string_literal: true

class CreateResources < ActiveRecord::Migration[7.1]
  def change
    create_table :resources do |t|
      t.string :name
      t.boolean :active
      t.integer :index

      t.timestamps
    end
  end
end
