require 'rake'
require 'rake/clean'
require_relative 'version'
require_relative 'lib/pockit/modpack'
require_relative 'lib/pockit/modlist'
require_relative 'lib/pockit/utility'

PACKAGE_DIRECTORY      = 'pkg'
PACKAGE_MODS_DIRECTORY = File.join(PACKAGE_DIRECTORY, 'mods')

# Downloads all mods in a list
# @param modlist [Pockit::Modlist] List of mods to download
# @return [null]
def download_list (modlist)
  modlist.each { |mod| Rake::Task['download_mod'].execute(mod) }
end

# Downloads a single mod
# @param mod [Pockit::Mod] Mod to download
# @return [null]
def download_mod (mod)
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
