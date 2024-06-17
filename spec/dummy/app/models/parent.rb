# frozen_string_literal: true

class Parent < ApplicationRecord
  enum :role, { principle: 0, teacher: 1, student: 2 }

  has_many :children, class_name: "Nested::Child"

  validates :name, presence: true

  scope :updated, ->(updated = true) { updated ? where.not(updated_at: nil) : where(updated_at: nil) }
end
