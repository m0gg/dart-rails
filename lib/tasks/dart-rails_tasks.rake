namespace :pub do

  # Launches 'pub get' in darts directory
  # requires DART_SDK_HOME or 'pub' to be in the PATH
  # TODO: more tasks for pub
  desc 'Launch "pub get" in app/assets/dart'
  task :get do
    if root = ENV['DART_SDK_HOME']
      file = File.join(root, 'bin', 'pub')
      pub = file if File.exist?(file)
    end
    pub ||= (system('pub version') ? 'pub' : false)
    system %Q{sh -c "cd #{Rails.root.join('app', 'assets', 'dart')}; #{pub} get"}
  end
end
