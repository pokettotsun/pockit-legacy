require 'rake'
require 'rake/clean'
require_relative 'version'
require_relative 'mod'
require_relative 'utility'

MODS_DIR  = 'mods'

CLEAN.include('*.zip')
CLEAN.include('*.jar')

task :default => ['download', 'package']

desc 'Creates the modpack package'
task :package => :download do
  zip_file   = "Pockit-#{Pockit::MODPACK_VERSION}.zip"
  jar_filter = "#{MODS_DIR}/*.jar"
  zip_filter = "#{MODS_DIR}/*.zip"
  zip(zip_file, jar_filter, zip_filter)
end

desc 'Downloads the mods to include in the modpack'
task :download do
  Dir.foreach(MODS_DIR) do |file|
    next if file.start_with?('.')
    next unless file.end_with?('.mod')
    mod = Mod.load("#{MODS_DIR}/#{file}")
    if ENV['http_user'] and ENV['http_pass']
      download_auth(mod.url, MODS_DIR, ENV['http_user'], ENV['http_pass'])
    else
      download(mod.url, MODS_DIR)
    end
  end
end

