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
      
      # returns a string containing a html script tag.
      # The src value will vary depending on the detected user agent.
      # "assets/dart_app.dart2js" if accessed from dartium.
      # "assets/dart_app.js" if accessed from other browsers.
      def auto_dart_include_tag(*args)
        opts = args.extract_options!
        tags = args.uniq.map do |fileName|
          if request.env['HTTP_USER_AGENT'].include? 'Dart'
            _to_dart_tag fileName, opts
          else
            _to_js_tag fileName, opts
          end
        end
        return tags.join('\n').html_safe
      end
      # options are always empty,currently
      def _to_dart_tag fileName, options
        tag_attributes = {
           'src':dart_path(fileName, options),
           'type':'application/dart'
        }
        tag_attributes = tag_attributes.merge options
        #generates a tag
        content_tag(:script, '',tag_attributes)
      end
      
      def _to_js_tag fileName, options
        options = {extname:'.dart2js'}.merge! options
        tag_attributes = {
          'src':path_to_asset(fileName, options),
           'type':'application/javascript'
        }
        tag_attributes = tag_attributes.merge options
        #generating a tag
        content_tag(:script, '',tag_attributes)
      end
      alias_method :path_to_dart, :dart_path
    end
  end
end
