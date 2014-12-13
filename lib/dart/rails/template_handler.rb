module Dart #:nodoc:
  module Rails #:nodoc:

    # TemplateHandler for dart scripts
    class TemplateHandler
      def self.erb_handler
        debugger
        @@erb_handler ||= ActionView::Template.registered_template_handler(:erb)
      end

      def self.call(template)
        debugger
        erb_handler.call(template)
      end
    end
  end
end

# Finally register TemplateHandler in ActionView
ActiveSupport.on_load(:action_view) do
  ActionView::Template.register_template_handler :dart, Dart::Rails::TemplateHandler
end