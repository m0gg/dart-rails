require 'fileutils'
require 'dart2js'

module Dart #:nodoc:
  module DirectiveProcessorDart2js

    def process_dart_directive(path)
      dart_path = resolve([path, '.dart'].join, { base_path: @dirname })

      process_depend_on_directive(dart_path)
      dart_get_dependencies(dart_path).each do |dep|
        process_depend_on_directive(dep)
      end

      #update Timestamp so we can compare possible changes
      FileUtils.touch @filename

      dart2js_compiler = ::Dart2Js.new(File.new(URI(dart_path).path), { out_dir: dart2js_out_dir })
      result = dart2js_compiler.compile

      if result.respond_to?(:exception)
        puts "\n------------- dart2js compilation exception -------------\n#{result.message}\n#{result.result}\n------------- dart2js compilation exception -------------"
        raise result
      end

      require_paths({ dart2js_compiler.out_file => @environment.stat(dart2js_compiler.out_file) }, Set.new)
    end

    private

    DART_EGREP = /^(import|part) ['"]((dart:){0}|(package:))[0-9a-zA-Z_\/\.\-]+\.dart['"];/
    DART_EGREP_PATH = /['"](package:)?(.*)['"]/

    def dart_get_dependencies(pathname, exceptions=[])
      deps = []
      #recursive search
      imports = dart_find_imports(pathname)
      imports.each do |dep|
        deps << dep unless deps.include?(dep)
      end
      (deps-exceptions).each do |path|
        dart_get_dependencies(path, deps)
      end
      deps
    end

    def dart_find_imports(pathname)
      deps = []
      File.exists?(pathname) && File.readlines(pathname).each do |l|
        #relevant line (import)?
        next unless DART_EGREP =~ l
        m = l.match(DART_EGREP_PATH)
        #package or part?
        deps << (m[1] ? resolve("packages/#{m[2]}") : "#{pathname.to_s.slice /^.*\//}#{m[2]}")
      end
      deps
    end

    def dart2js_out_dir
      Dart::Rails::JsCompatEngine::DART2JS_OUT_DIR
    end
  end
end
