require 'rails'
require 'rails/railtie'
require 'dart2js'
require 'sprockets'
require 'dart/sprockets/directive_processor_dart2js'
require 'dart/rails/engine'
require 'dart/rails/template_handler'
require 'dart/rails/version'
require 'dart/rails/helper'
require 'dart/rails/generators/assets/generator'


module Dart
  class Railtie < ::Rails::Railtie

    initializer :assets do |app|
      hash = (Digest::MD5.new << Time.now.to_s).to_s
      Dart::DART2JS_OUT_DIR = app.root.join('tmp', 'cache', 'assets', 'development', 'dart', hash)

      # precompile compatibility-script
      ::Rails.application.config.assets.precompile << 'dart.js'
      ::Rails.application.config.assets.precompile << 'dart_app.js'

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

      # make dart2js results accessible for sprockets
      app.assets.append_path(Dart::DART2JS_OUT_DIR)

      # Mixin process_dart_directive in standard DirectiveProcessor for JS
      Sprockets::DirectiveProcessor.instance_eval do
        include Dart::DirectiveProcessorDart2js
      end
    end

    config.after_initialize do |app|
      # Mixin helper-module in ActionView
      ActionView::Base.instance_eval do
        include Dart::Rails::Helper
      end
    end
  end
end
