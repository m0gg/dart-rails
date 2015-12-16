require 'rails'
require 'rails/railtie'
require 'dart/rails/version'
require 'dart/rails/dart_asset_helper'
require 'dart/rails/js_compat_engine'
require 'dart/rails/generators/assets/generator'


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
