# frozen_string_literal: true

class Resource < ApplicationRecord
  validates :name, presence: true
end
