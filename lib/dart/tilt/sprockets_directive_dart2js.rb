require 'fileutils'

module Dart
  module SprocketsDirectiveDart2js
    def process_dart_directive path
      pathname = context.resolve([path, '.dart'].join)

      transcoder = DartJs.new(File.new(pathname), options.merge({ out_dir: Dart::DART2JS_OUT_DIR }))
      result = transcoder.compile
      if result.respond_to?(:exception)
        puts "------------- dart2js compilation exception -------------\n#{result.message}\n#{result.result}\n------------- dart2js compilation exception -------------\n"
        raise result
      end

      context.depend_on_asset(transcoder.out_file)
      included_pathnames << transcoder.out_file
    end
  end
end