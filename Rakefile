require 'rake'
require 'rake/clean'
require_relative 'version'
require_relative 'mod'
require_relative 'utility'

MODS_DIR    = 'mods'
MODPACK_DIR = 'modpack'

CLEAN.include('*.zip')
CLEAN.include('*.jar')
CLEAN.include("#{MODS_DIR}/*.zip")
CLEAN.include("#{MODS_DIR}/*.jar")
CLEAN.include(MODPACK_DIR)

task :default => ['download', 'package']

desc 'Creates the modpack package'
task :package => :download do
  zip_file = "Pockit-#{Pockit::MODPACK_VERSION}.zip"
  if Dir.exist?(MODPACK_DIR)
    sh "cd '#{MODPACK_DIR}' && zip -qrg ../modpack.jar *"
    zip(zip_file, 'modpack.jar')
  end

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
  output_file = if http_auth
    download_auth(mod.url, MODS_DIR, ENV['http_user'], ENV['http_pass'])
  else
    download(mod.url, MODS_DIR)
  end
  Rake::Task['extract_mod'].execute(output_file) if mod.core
end

desc 'Extracts the contents of a mod into the core mod directory'
task :extract_mod, [:mod_file] do |t, mod_file|
  sh "unzip -qo -d '#{MODPACK_DIR}' '#{mod_file}'"
end

# Checks whether HTTP authentication is provided
# @return [Boolean]
def http_auth
  ENV['http_user'] and ENV['http_pass']
end

