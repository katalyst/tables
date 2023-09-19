# frozen_string_literal: true

require "view_component"

require_relative "tables/backend"
require_relative "tables/engine"
require_relative "tables/frontend"
require_relative "tables/version"

require_relative "tables/engine" if Object.const_defined?(:Rails)

module Katalyst
  module Tables
    class Error < StandardError; end
  end
end
