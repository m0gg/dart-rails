require 'fileutils'

module Dart
  module DirectiveProcessorDart2js
    def process_dart_directive(path)
      pathname = context.resolve([path, '.dart'].join)
      pathname_js = context.resolve([path, '.js'].join)

      ensure_dart2js_out_dir_exists

      transcoder = DartJs.new(File.new(pathname), options.merge({ out_dir: Dart::DART2JS_OUT_DIR }))
      result = transcoder.compile

      #update Timestamp so we can compare possible changes
      FileUtils.touch pathname_js

      if result.respond_to?(:exception)
        puts "\n------------- dart2js compilation exception -------------\n#{result.message}\n#{result.result}\n------------- dart2js compilation exception -------------"
        raise result
      end

      context.depend_on(pathname)
      dart_get_dependencies(pathname).each do |dep|
        context.depend_on(dep)
      end
      included_pathnames << transcoder.out_file
    end

    private

    DART_EGREP = /^(import|part) ['"]((dart:){0}|(package:))[0-9a-zA-Z_\/\.\-]+\.dart['"];/
    DART_EGREP_PATH = /['"](package:)?(.*)['"]/

    def dart_get_dependencies(pathname)
      deps = []
      if File.exists?(pathname)
        f = File.open(pathname)
        f.each do |l|
          if DART_EGREP =~ l
            m = l.match(DART_EGREP_PATH)
            dep_path = (m[1] ? "packages/#{m[2]}" : m[2])
            deps << context.resolve(dep_path)
          end
        end
        f.close
        rdeps = []
        deps.each do |dep|
          rdeps += dart_get_dependencies(dep)
        end
        return (deps + rdeps).uniq
      end
      return nil
    end

    def ensure_dart2js_out_dir_exists
      FileUtils.mkdir_p Dart::DART2JS_OUT_DIR unless File.directory?(Dart::DART2JS_OUT_DIR)
    end
  end
end
