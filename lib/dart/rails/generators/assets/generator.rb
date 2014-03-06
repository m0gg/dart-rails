require 'rails/generators'

module Dart
  module Generators
    class AssetsGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      # Copies contents of template/dart to assets
      # invoke with:
      #
      #   $# rails g dart:assets
      #
      def generate_dart
        directory 'dart', 'app/assets/dart/'
      end
    end
  end
end
