# frozen_string_literal: true

class CreateFaqs < ActiveRecord::Migration[7.1]
  def change
    create_table :faqs do |t|
      t.string :question
      t.string :answer
      t.integer :ordinal

      t.timestamps
    end
  end
end
