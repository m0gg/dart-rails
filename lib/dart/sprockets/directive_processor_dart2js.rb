require 'fileutils'

module Dart
  module DirectiveProcessorDart2js
    def process_dart_directive(path)
      pathname = context.resolve([path, '.dart'].join)

      ensure_dart2js_out_dir_exists

      transcoder = DartJs.new(File.new(pathname), options.merge({ out_dir: Dart::DART2JS_OUT_DIR }))
      result = transcoder.compile

      if result.respond_to?(:exception)
        puts "\n------------- dart2js compilation exception -------------\n#{result.message}\n#{result.result}\n------------- dart2js compilation exception -------------"
        raise result
      end

      context.depend_on_asset(transcoder.out_file)
      included_pathnames << transcoder.out_file
    end

    private

    def ensure_dart2js_out_dir_exists
      FileUtils.mkdir_p Dart::DART2JS_OUT_DIR unless File.directory?(Dart::DART2JS_OUT_DIR)
    end
  end
end
