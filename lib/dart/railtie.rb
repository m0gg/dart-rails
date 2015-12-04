require 'rails'
require 'rails/railtie'
require 'dart/rails/version'
require 'dart/rails/dart_asset_helper'
require 'dart/rails/js_compat_engine'
require 'dart/rails/generators/assets/generator'


module Dart #:nodoc:
  class Railtie < ::Rails::Railtie

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
      puts 'No non-stupid-digest-assets support. You may face issues with native dart-support!'
    end

    config.after_initialize do |app|
      # Mixin helper-module in ActionView
      ActionView::Base.instance_eval do
        include Dart::Rails::DartAssetHelper
      end
    end
  end
end
