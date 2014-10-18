require 'rake'
require 'rake/clean'
require_relative 'version'
require_relative 'lib/pockit/modpack'
require_relative 'lib/pockit/modlist'
require_relative 'lib/pockit/utility'

PACKAGE_DIRECTORY      = 'pkg'
PACKAGE_MODS_DIRECTORY = File.join(PACKAGE_DIRECTORY, 'mods')

desc 'Downloads all mods in a list'
task :download, [:modlist] do |t, modlist|
  list = modlist.is_a?(Pockit::Modlist) ? modlist : Pockit::Modlist.load(modlist)
  list.each { |mod| Rake::Task['download_mod'].execute(mod) }
end

desc 'Downloads a single mod'
task :download_mod, [:mod] do |t, mod|
  info = mod.is_a?(Pockit::Mod) ? mod : Pockit::Mod.load(mod)
  file = Pockit::Utility.url_filename(mod.url)
  dest = File.join(PACKAGE_MODS_DIRECTORY, file)
  
  if http_auth
    Pockit::Utility.download_auth(mod.url, dest, ENV['http_user'], ENV['http_pass'])
  else
    Pockit::Utility.download(mod.url, dest)
  end
end

# Checks whether HTTP authentication is provided
# @return [Boolean]
def http_auth
  ENV['http_user'] and ENV['http_pass']
end
