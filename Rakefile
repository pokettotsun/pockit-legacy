require 'rake'
require 'rake/clean'
require_relative 'version'
require_relative 'mod'
require_relative 'utility'

MODS_DIR = 'mods'

CLEAN.include('*.zip')
CLEAN.include('*.jar')
CLEAN.include("#{MODS_DIR}/*.zip")
CLEAN.include("#{MODS_DIR}/*.jar")

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
  Dir.foreach(MODS_DIR) do |filename|
    next if filename.start_with?('.')
    next unless filename.end_with?('.mod')
    Rake::Task['download_mod'].execute(filename)
  end
end

desc 'Download a specific mod'
task :download_mod, [:mod_file] do |t, mod_file|
  mod_path = File.join(MODS_DIR, mod_file)
  mod = Mod.load(mod_path)
  if http_auth
    download_auth(mod.url, MODS_DIR, ENV['http_user'], ENV['http_pass'])
  else
    download(mod.url, MODS_DIR)
  end
end

# Checks whether HTTP authentication is provided
# @return [Boolean]
def http_auth
  ENV['http_user'] and ENV['http_pass']
end

