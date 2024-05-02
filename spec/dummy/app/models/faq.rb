# frozen_string_literal: true

class Faq < ApplicationRecord
  has_rich_text :answer

  default_scope -> { order(ordinal: :asc) }
end
