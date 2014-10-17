require 'rake'
require 'rake/clean'
require_relative 'version'
require_relative 'mod'
require_relative 'utility'

MODS_DIR       = 'mods'
CORE_MODS_DIR  = 'coremods'
JAR_PATCH_DIR  = 'jar'
SERVER_ZIP     = 'http://code.mikedevblog.com:8080/repository/mc_mods/net/minecraftforge/minecraft-server-forge/1.7.10/minecraft-server-forge-1.7.10.zip'
SERVER_PKG_DIR = 'server-pkg'

CLEAN.include('*.zip')
CLEAN.include('*.jar')
CLEAN.include("#{MODS_DIR}/*.zip")
CLEAN.include("#{MODS_DIR}/*.jar")
CLEAN.include(JAR_PATCH_DIR)
CLEAN.include(CORE_MODS_DIR)
CLEAN.include(SERVER_PKG_DIR)
CLEAN.include('bin')

task :default => ['download', 'modpack', 'server']

desc 'Creates the client modpack package'
task :modpack => :download do
  zip_file = "Pockit-#{Pockit::MODPACK_VERSION}.zip"
  if Dir.exist?(JAR_PATCH_DIR)
    Dir.mkdir('bin') unless Dir.exist?('bin')
    sh "cd '#{JAR_PATCH_DIR}' && zip -qr ../bin/modpack.jar *"
    zip(zip_file, 'bin/modpack.jar')
  end

  mods_jar_filter = "#{MODS_DIR}/*.jar"
  mods_zip_filter = "#{MODS_DIR}/*.zip"
  core_jar_filter = "#{CORE_MODS_DIR}/*.jar"
  core_zip_filter = "#{CORE_MODS_DIR}/*.zip"
  zip(zip_file, mods_jar_filter, mods_zip_filter, core_jar_filter, core_zip_filter)
end

desc 'Creates the server package'
task :server => :download do
  zip_file = "Pockit-server-#{Pockit::MODPACK_VERSION}.zip"
  Dir.mkdir(SERVER_PKG_DIR) unless Dir.exist?(SERVER_PKG_DIR)
  server_artifact = if http_auth
    download_auth(SERVER_ZIP, '.', ENV['http_user'], ENV['http_pass'])
  else
    download(SERVER_ZIP, '.')
  end
  sh "unzip -qo -d #{SERVER_PKG_DIR} #{server_artifact}"
  sh "cd #{SERVER_PKG_DIR} && zip -r ../#{zip_file} *"
  mods_jar_filter = "#{MODS_DIR}/*.jar"
  mods_zip_filter = "#{MODS_DIR}/*.zip"
  core_jar_filter = "#{CORE_MODS_DIR}/*.jar"
  core_zip_filter = "#{CORE_MODS_DIR}/*.zip"
  zip(zip_file, mods_jar_filter, mods_zip_filter, core_jar_filter, core_zip_filter)
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
  mod_dir = mod.coremod? ? CORE_MODS_DIR : MODS_DIR
  output_file = if http_auth
    download_auth(mod.url, mod_dir, ENV['http_user'], ENV['http_pass'])
  else
    download(mod.url, mod_dir)
  end
  Rake::Task['extract_mod'].execute(output_file) if mod.jar_patch?
end

desc 'Extracts the contents of a mod into the core mod directory'
task :extract_mod, [:mod_file] do |t, mod_file|
  sh "unzip -qo -d '#{JAR_PATCH_DIR}' '#{mod_file}'"
end

# Checks whether HTTP authentication is provided
# @return [Boolean]
def http_auth
  ENV['http_user'] and ENV['http_pass']
end

