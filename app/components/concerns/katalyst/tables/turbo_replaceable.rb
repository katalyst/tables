# frozen_string_literal: true

module Katalyst
  module Tables
    # Adds support for turbo stream replacement to ViewComponents. Components
    # that are rendered from a turbo-stream-compatible response will be rendered
    # using turbo stream replacement. Components must define `id`.
    #
    # Turbo stream replacement rendering will only be enabled if the component
    # passes `turbo: true` as a constructor option.
    module TurboReplaceable
      extend ActiveSupport::Concern

      include ::Turbo::StreamsHelper

      def turbo?
        @turbo
      end

      def initialize(turbo: true, **options)
        super(**options)

        @turbo = turbo
      end

      class_methods do
        # Redefine the compiler to use our custom compiler.
        # Compiler is set on `inherited` so we need to re-set it if it's not the expected type.
        def compiler
          @vc_compiler = @vc_compiler.is_a?(TurboCompiler) ? @vc_compiler : TurboCompiler.new(self)
        end
      end

      included do
        # ensure that our custom compiler is used, as `inherited` calls `compile` before our module is included.
        compile(force: true) if compiled?
      end

      # Wraps the default compiler provided by ViewComponent to add turbo support.
      class TurboCompiler < ViewComponent::Compiler
        private

        def define_render_template_for # rubocop:disable Metrics/MethodLength
          super

          redefinition_lock.synchronize do
            component_class.alias_method(:vc_render_template_for, :render_template_for)
            component_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def render_template_for(variant = nil)
              return vc_render_template_for(variant) unless turbo?
              controller.respond_to do |format|
                format.html { vc_render_template_for(variant) }
                format.turbo_stream { turbo_stream.replace(id, vc_render_template_for(variant)) }
              end
            end
            RUBY
          end
        end
      end
    end
  end
end
