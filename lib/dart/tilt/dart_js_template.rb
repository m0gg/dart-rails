require 'tilt/template'
require 'fileutils'

module Dart
  module Tilt

    # Tile-tmplate for processing dart files
    # provides js-code from dart2js
    class DartJsTemplate < ::Tilt::Template

      # TODO: is this needed?
      self.default_mime_type = 'application/dart'

      # checks for required DartJs class
      def self.engine_initialized?
        defined? ::DartJs
      end

      # requires DartJs from ruby-dart_js
      # TODO: is this needed?
      def initialize_engine
        require_template_library('dart_js')
      end

      # Setup path to applications tmp directory
      # TODO: super-method not called, required?
      def prepare
        tmp_path = ::Rails.root.join('tmp', 'dart').to_s
        FileUtils.mkdir_p tmp_path
        options[:tmp_path] ||= tmp_path
      end

      # Returns transcoded dart template
      # TODO: respect paramters, if thats relevant
      def evaluate(scope, locals, &block)
        transcoder = DartJs.new((@file ? File.new(@file) : data), options)
        if transcoder.compile
          puts transcoder.result
          @output ||= transcoder.get_js_content
        else
          # TODO: make it an error someone can work with
          throw 'dart2js compiler failed!'
        end
      end
    end
  end
end