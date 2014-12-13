require 'rails/engine'

module Dart #:nodoc:
  module Rails #:nodoc:
    class JsCompatEngine < ::Rails::Engine

      # Handle gem provided javascripts
      initializer :assets do |app|

        #initialize dart2js dir
        hash = (Digest::MD5.new << Time.now.to_s).to_s
        DART2JS_OUT_DIR = app.root.join('tmp', 'cache', 'assets', 'development', 'dart', hash)
        FileUtils.mkdir_p DART2JS_OUT_DIR unless File.directory?(DART2JS_OUT_DIR)

        # make dart.js compatibility-script accessible for sprockets
        app.assets.append_path(File.join(root, 'lib', 'assets', 'javascripts'))

        # make dart2js results accessible for sprockets
        app.assets.append_path(Dart::Rails::JsCompatEngine::DART2JS_OUT_DIR)

        # precompile compatibility-script(s)
        # TODO: does not work with `app.assets.precompile += ...`
        ::Rails.application.config.assets.precompile += %w(dart_app.js dart.js)


        # Mixin process_dart_directive in standard DirectiveProcessor for JS
        Sprockets::DirectiveProcessor.instance_eval do
          include Dart::DirectiveProcessorDart2js
        end
      end
    end
  end
end