# frozen_string_literal: true

class AddFriendsToPeople < ActiveRecord::Migration[8.0]
  def change
    create_table :people_friends, id: false do |t|
      t.belongs_to :person
      t.belongs_to :friend
    end
  end
end
