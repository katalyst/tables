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

      # Is turbo rendering enabled for this component?
      def turbo?
        @turbo
      end

      # Are we rendering a turbo stream response?
      def turbo_stream_response?
        response.media_type.eql?("text/vnd.turbo-stream.html")
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
            # Capture the instance method added by the default compiler and
            # wrap it in a turbo stream replacement. Take care to ensure that
            # subclasses of this component don't break delegation, as each
            # subclass of ViewComponent::Base defines its own version of this
            # method.
            vc_render_template = component_class.instance_method(:render_template_for)
            component_class.define_method(:render_template_for) do |variant = nil|
              # VC discards the output from this method and uses the buffer
              # if both are set. Capture and wrap the output.
              content = capture { vc_render_template.bind_call(self, variant) }
              # In turbo mode, replace the inner-most element using a turbo
              # stream. Note that we only want one turbo stream per component
              # from this mechanism, as subclasses may want to concat their
              # own additional streams.
              if turbo? && turbo_stream_response? && !@streamed
                @streamed = true
                concat(turbo_stream.replace(id, content))
              else
                concat(content)
              end
            end
          end
        end
      end
    end
  end
end
