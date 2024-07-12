# frozen_string_literal: true

require "active_support"

module Katalyst
  module Tables
    extend ActiveSupport::Autoload

    autoload :Config

    class Error < StandardError; end

    def self.config
      @config ||= Config.new
    end

    def self.configure
      yield config
    end
  end
end

require "katalyst/tables/engine"
