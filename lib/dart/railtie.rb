require 'rails'
require 'rails/railtie'
require 'dart_js'
require 'sprockets'
require 'dart/tilt/sprockets_directive_dart2js'
require 'dart/rails/engine'
require 'dart/rails/template_handler'
require 'dart/rails/version'
require 'dart/rails/helper'
require 'dart/rails/generators/assets/generator'

module Dart
  class Railtie < ::Rails::Railtie

    initializer :assets do |config|
      ::Rails.application.config.assets.precompile << 'dart.js'
    end

    config.after_initialize do |app|
      Dart::DART2JS_OUT_DIR = ::Rails.root.join('tmp', 'cache')

      # Register mime-types and Tilt-templates in assets environment
      app.assets.register_mime_type 'application/dart', '.dart'

      # make dart2js results accessible for sprockets
      app.assets.append_path(Dart::DART2JS_OUT_DIR)

      # Mixin process_dart_directive in standard DirectiveProcessor for JS
      Sprockets::DirectiveProcessor.instance_eval do
        include Dart::SprocketsDirectiveDart2js
      end

      # Mixin helper-module in ActionView
      ActionView::Base.instance_eval do
        include Dart::Rails::Helper
      end
    end
  end
end