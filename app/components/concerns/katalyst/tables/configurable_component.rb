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
        # Sub-components are cached on the table instance. We want to allow run
        # time mixins for tables so that we can extend tables with cross-cutting
        # concerns that affect multiple sub-components by including the concern
        # into the top-level table class. We achieve this by subclassing the
        # component as soon as it is created so that when a mixin is added to
        # the table class, it can immediately retrieve and modify the
        # sub-component class as well without needing to worry about affecting
        # other tables.
        def config_component(name, component_name: "#{name}_component", default: nil) # rubocop:disable Metrics/MethodLength
          config_accessor(name)
          config.public_send("#{name}=", default)
          define_method(component_name) do
            return instance_variable_get("@#{component_name}") if instance_variable_defined?("@#{component_name}")

            klass     = config.public_send(name)
            component = klass ? self.class.const_get(klass) : nil

            # subclass to allow table-specific extensions
            if component
              component = Class.new(component)
              component.extend(HiddenSubcomponent)
            end

            instance_variable_set("@#{component_name}", component) if component
          end
        end
      end

      # View Component uses `name` to resolve the template path, so we need to
      # hide the subclass from the template resolver.
      module HiddenSubcomponent
        delegate :name, to: :superclass
      end
    end
  end
end
