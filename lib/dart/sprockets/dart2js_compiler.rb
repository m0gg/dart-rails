require 'tilt/template'
require 'dart2js'

module Dart
  class Dart2JsCompiler < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def self.engine_initialized?
      defined? ::Dart2Js
    end

    def initialize_engine
      unless defined? ::Dart2Js
        require_template_library 'dart2js'
      end
    end

    def prepare
    end

    def self.call(input)
      # it's necessary for dart2js to have the dart file in th same directory as its depencencies
      compiler = ::Dart2Js.new(input[:data], pwd: File.dirname(input[:filename]))
      result = compiler.compile
      compiler.close
      result
    end

    def evaluate(context, locals, &block)
      self.class.call({ filename: context.pathname, data: data })
    end
  end
end