# frozen_string_literal: true

class Person < ApplicationRecord
  scope :table_search, ->(query) { where(arel_table[:name].matches("%#{sanitize_sql_like(query)}%")) }
end
