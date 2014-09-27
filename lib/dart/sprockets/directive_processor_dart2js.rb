require 'fileutils'

module Dart
  module DirectiveProcessorDart2js
    def process_dart_directive(path)
      pathname = context.resolve([path, '.dart'].join)

      ensure_directories_exist

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

    def ensure_directories_exist
      path = Dart::DART2JS_OUT_DIR
      directories = path.sub((::Rails.root.to_s + '/'), '').split('/')
      folder_path = ::Rails.root.to_s

      directories.each do |directory|
        folder_path += '/' + directory
        Dir.mkdir folder_path unless File.directory? folder_path
      end
    end
  end
end
