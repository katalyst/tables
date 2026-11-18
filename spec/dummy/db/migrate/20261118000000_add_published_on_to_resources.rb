# frozen_string_literal: true

class AddPublishedOnToResources < ActiveRecord::Migration[8.0]
  def change
    add_column :resources, :published_on, :date
  end
end
