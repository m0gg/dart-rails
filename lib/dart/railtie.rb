require 'rails'
require 'rails/railtie'
require 'dart/sprockets/directive_processor_dart2js'
require 'dart/rails/version'
require 'dart/rails/js_compat_engine'
require 'dart/rails/dart_asset_helper'
require 'dart/rails/generators/assets/generator'
require 'dart/rails/template_handler'


module Dart #:nodoc:
  class Railtie < ::Rails::Railtie

    config.after_initialize do |app|
      # Mixin helper-module in ActionView
      ActionView::Base.instance_eval do
        include Dart::Rails::DartAssetHelper
      end
    end
  end
end
