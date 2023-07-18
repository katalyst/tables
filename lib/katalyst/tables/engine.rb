# frozen_string_literal: true

require "rails"

module Katalyst
  module Tables
    class Engine < ::Rails::Engine # :nodoc:
      isolate_namespace Katalyst::Tables
    end
  end
end
