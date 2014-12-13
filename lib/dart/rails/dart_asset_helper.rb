require 'action_view'

module Dart #:nodoc:
  module Rails #:nodoc:

    # ActionView helper mixin for dart
    module DartAssetHelper

      # Returns html_safe dart/application script tag.
      # Example:
      #
      #   '<script src="/assets/dart_app.dart" type="application/dart"></script>'
      #
      # Remember: only one dart script-tag is allowed!
      def dart_include_tag(*sources)
        options = sources.extract_options!.stringify_keys
        sources.uniq.map { |source|
          tag_options = {
            'src' => dart_path(source, options),
            'type' => 'application/dart'
          }.merge(options)
          content_tag(:script, '', tag_options)
        }.join('\n').html_safe
      end

      # Returns path to dart script, similar to javascript_path
      def dart_path(source, options = {})
        path_to_asset(source, { :extname => '.dart' }.merge!(options))
      end

      alias_method :path_to_dart, :dart_path
    end
  end
end
