# frozen_string_literal: true

class Person < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :archived, -> { unscope(where: :active).where.not(active: true) }
  scope :table_search, ->(query) { where(arel_table[:name].matches("%#{sanitize_sql_like(query)}%")) }
end
