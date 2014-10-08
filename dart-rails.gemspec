$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'dart/rails/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'dart-rails'
  s.version     = Dart::Rails::VERSION
  s.authors     = ['Marcel Sackermann']
  s.email       = %w(marcel@m0gg.org)
  s.homepage    = 'https://github.com/m0gg/dart-rails'
  s.summary     = 'Provides Sprockets based handling of .dart files'
  s.description = 'Delivers .dart directly to Dartium-browser and transcodes via ruby-dart_js for others.'

  s.files = Dir['{lib}/**/*'] + %w(MIT-LICENSE Rakefile) #, 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '>= 3.0.0'
  s.add_dependency 'ruby-dart2js', '~> 0.1.0'
  s.add_dependency 'sprockets-rails', '>= 2.0.0'
end
