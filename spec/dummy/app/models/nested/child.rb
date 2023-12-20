# frozen_string_literal: true

module Nested
  class Child < ApplicationRecord
    belongs_to :parent, class_name: "Parent"

    validates :name, presence: true
  end
end
