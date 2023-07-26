# frozen_string_literal: true

module Katalyst
  module Tables
    module ConfigurableComponent # :nodoc:
      extend ActiveSupport::Concern

      include ActiveSupport::Configurable

      included do
        # Workaround: ViewComponent::Base.config is incompatible with ActiveSupport::Configurable
        @_config = Class.new(ActiveSupport::Configurable::Configuration).new
      end

      class_methods do
        # Define a configurable sub-component.
        def config_component(name, component_name: "#{name}_component", default: nil)
          config_accessor(name)
          config.public_send("#{name}=", default)
          define_method(component_name) do
            instance_variable_get("@#{component_name}") if instance_variable_defined?("@#{component_name}")

            klass     = config.public_send(name)
            component = self.class.const_get(klass) if klass
            instance_variable_set("@#{component_name}", component) if component
          end
        end
      end
    end
  end
end
