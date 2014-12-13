require 'rails/engine'

module Dart #:nodoc:
  module Rails #:nodoc:
    class DartEngine < ::Rails::Engine

      initializer :assets do |app|

        # [Optionally via: https://github.com/m0gg/non-stupid-digest-assets]
        # do not digest .dart files
        # digest during compilation breaks darts 'import' functionality
        # currently sprockets-rails does not allow mixed procompilation of digest and non-digest assets
        # see https://github.com/rails/sprockets-rails/issues/49
        # workaround is a 51-liner gem 'non-stupid-digest-assets'
        # https://github.com/alexspeller/non-stupid-digest-assets
        #
        begin
          require 'non-stupid-digest-assets'
          if defined? NonStupidDigestAssets
            NonStupidDigestAssets.whitelist += [ /.*\.dart/, 'dart_app.js', 'dart_app' ]
          end
        rescue Exception => e
          ::Rails.logger.info 'No non-stupid-digest-assets support. You may face issues with native dart-support!'
        end

        # Register mime-types
        app.assets.register_mime_type 'application/dart', '.dart'
      end
    end
  end
end