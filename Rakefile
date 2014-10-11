require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require_relative 'version'
require_relative 'mod'
require_relative 'utility'

MODS_DIR  = 'mods'

CLEAN.include('*.zip')

task :default => ['download', 'package']

desc 'Creates the modpack package'
Rake::PackageTask.new('pockit', Pockit::MODPACK_VERSION) do |p|
  p.need_zip = true
  p.package_files.include("#{MODS_DIR}/*.jar")
  p.package_files.include("#{MODS_DIR}/*.zip")
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

