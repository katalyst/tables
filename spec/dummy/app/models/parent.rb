# frozen_string_literal: true

class Parent < ApplicationRecord
  has_many :children, class_name: "Nested::Child"

  validates :name, presence: true
end
