# frozen_string_literal: true

class Resource < ApplicationRecord
  enum :category, { article: 0, documentation: 1, report: 2 }

  validates :name, :category, presence: true

  has_one_attached :image do |image|
    image.variant :thumb, resize_to_fill: [100, 100]
  end

  scope :active, -> { where(active: true) }
end
