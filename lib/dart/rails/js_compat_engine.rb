require 'rails/engine'

module Dart #:nodoc:
  module Rails #:nodoc:
    class JsCompatEngine < ::Rails::Engine

      # Handle gem provided javascripts
      initializer :assets do |app|

        # make dart.js compatibility-script accessible for sprockets
        ::Rails.application.config.assets.append_path(File.join(root, 'lib', 'assets', 'javascripts'))

        # precompile compatibility-script(s)
        ::Rails.application.config.assets.precompile += %w(dart_app.js dart.js)
      end
    end
  end
end
