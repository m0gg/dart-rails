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

    def evaluate(context, locals, &block)
      compiler = ::Dart2Js.new(File.new(context.pathname))
      if (e = compiler.compile(false)).is_a?(::Dart2JsExceptions::CompilationException)
        "alert(\"dart2js failed to compile: #{e}\");"
      else
        compiler.get_js_content
      end
    end
  end
end