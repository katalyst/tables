# frozen_string_literal: true

require_relative "tables/backend"
require_relative "tables/frontend"
require_relative "tables/version"

module Katalyst
  module Tables
    class Error < StandardError; end
  end
end
