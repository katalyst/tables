# frozen_string_literal: true

module Nested
  class Child < ApplicationRecord
    belongs_to :parent, class_name: "Parent"

    validates :name, presence: true

    scope :parent_updated, ->(value) { joins(:parent).merge(Parent.updated(value)) }
  end
end
