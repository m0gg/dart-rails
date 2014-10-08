require 'fileutils'

module Dart
  module DirectiveProcessorDart2js
    def process_dart_directive(path)
      dart_path = context.resolve([path, '.dart'].join)

      dart2js_compiler = ::Dart2Js.new(File.new(dart_path), options.merge({ out_dir: dart2js_out_dir }))
      result = dart2js_compiler.compile

      #update Timestamp so we can compare possible changes
      FileUtils.touch @pathname

      if result.respond_to?(:exception)
        puts "\n------------- dart2js compilation exception -------------\n#{result.message}\n#{result.result}\n------------- dart2js compilation exception -------------"
        raise result
      end

      context.depend_on(dart_path)
      dart_get_dependencies(dart_path).each do |dep|
        context.depend_on(dep)
      end
      included_pathnames << dart2js_compiler.out_file
    end

    private

    DART_EGREP = /^(import|part) ['"]((dart:){0}|(package:))[0-9a-zA-Z_\/\.\-]+\.dart['"];/
    DART_EGREP_PATH = /['"](package:)?(.*)['"]/

    def dart_get_dependencies(pathname)
      deps = dart_find_imports(pathname)
      #recursive search
      deps += deps.map do |dep|
        dart_get_dependencies(dep)
      end
      deps.uniq.flatten
    end

    def dart_find_imports(pathname)
      deps = []
      File.exists?(pathname) && File.readlines(pathname).each do |l|
        #relevant line (import)?
        next unless DART_EGREP =~ l
        m = l.match(DART_EGREP_PATH)
        #package or part?
        dep_path = (m[1] ? "packages/#{m[2]}" : m[2])
        deps << context.resolve(dep_path)
      end
      deps
    end

    def dart2js_out_dir
      FileUtils.mkdir_p Dart::DART2JS_OUT_DIR unless File.directory?(Dart::DART2JS_OUT_DIR)
      Dart::DART2JS_OUT_DIR
    end
  end
end
