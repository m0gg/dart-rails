require 'rails/engine'

module Dart #:nodoc:
  module Rails #:nodoc:
    class DartEngine < ::Rails::Engine

      initializer :assets do |app|

        # Register mime-types
        app.assets.register_mime_type 'application/dart', '.dart'
      end
    end
  end
end