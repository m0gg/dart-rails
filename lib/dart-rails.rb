require 'dart/railtie'
require 'dart/sprockets/dart2js_compiler'

module Dart
  Sprockets.register_engine '.dart2js', Dart2JsCompiler
end
