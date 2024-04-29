# frozen_string_literal: true

class Faq < ApplicationRecord
  default_scope -> { order(ordinal: :asc) }
end
