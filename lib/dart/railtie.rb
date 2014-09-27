require 'rails'
require 'rails/railtie'
require 'dart_js'
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
