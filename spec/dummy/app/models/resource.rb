# frozen_string_literal: true

class Resource < ApplicationRecord
  validates :name, presence: true

  has_one_attached :image do |image|
    image.variant :thumb, resize_to_fill: [100, 100]
  end
end
