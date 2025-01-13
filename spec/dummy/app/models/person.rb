# frozen_string_literal: true

class Person < ApplicationRecord
  has_and_belongs_to_many :friends,
                          class_name:              "Person",
                          join_table:              :people_friends,
                          association_foreign_key: :friend_id,
                          delete:                  :cascade

  scope :active, -> { where(active: true) }
  scope :archived, -> { unscope(where: :active).where.not(active: true) }
  scope :table_search, ->(query) { where(arel_table[:name].matches("%#{sanitize_sql_like(query)}%")) }
end
