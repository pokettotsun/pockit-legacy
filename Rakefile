require 'rake'
require 'rake/clean'
require_relative 'version'
require_relative 'mod'
require_relative 'utility'

MODS_DIR  = 'mods'
BUILD_DIR = 'build'

CLEAN.include('*.zip')

task :default => ['download', 'package']

desc 'Creates the modpack package'
task :package => :download do
  sh 'echo "IMPLEMENT ME"'
end

desc 'Downloads the mods to include in the modpack'
task :download do
  Dir.mkdir(BUILD_DIR) unless Dir.exist?(BUILD_DIR)
  Dir.mkdir("#{BUILD_DIR}/mods") unless Dir.exist?("#{BUILD_DIR}/mods")
  Dir.foreach(MODS_DIR) do |file|
    next if file.start_with?('.')
    mod = Mod.load("#{MODS_DIR}/#{file}")
    if ENV['http_user'] and ENV['http_pass']
      download_auth(mod.url, "#{BUILD_DIR}/mods", ENV['http_user'], ENV['http_pass'])
    else
      download(mod.url, "#{BUILD_DIR}/mods")
    end
  end
end

