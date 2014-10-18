require 'rake'
require 'rake/clean'
require_relative 'version'
require_relative 'lib/pockit/modpack'
require_relative 'lib/pockit/modlist'
require_relative 'lib/pockit/utility'

TEMP_DIRECTORY             = 'tmp'
PACKAGE_DIRECTORY          = 'pkg'
PACKAGE_MODS_DIRECTORY     = File.join(PACKAGE_DIRECTORY, 'mods')
PACKAGE_COREMODS_DIRECTORY = File.join(PACKAGE_DIRECTORY, 'coremods')

# Downloads all mods in a list
# @param modlist [Pockit::Modlist] List of mods to download
# @return [null]
def download_list (modlist)
  count  = modlist.length
  done   = 0
  length = count.to_s.length * 2 + 1 # count size, /, done size
  format = "%#{length}d"
  modlist.each do |mod|
    progress = sprintf(format, "#{count}/#{done}")
    puts "[#{progress}] #{mod.name}: #{mod.url}"
    download_mod(mod)
    count += 1
  end
end

# Downloads a single mod
# @param mod [Pockit::Mod] Mod to download
# @return [null]
def download_mod (mod)
  file = Pockit::Utility.url_filename(mod.url)
  dir  = case mod.type
  when :core then PACKAGE_COREMODS_DIRECTORY
  when :jar  then TEMP_DIRECTORY
  else            PACKAGE_MODS_DIRECTORY
  end
  dest = File.join(dir, file)
  FileUtils.mkpath(dir) unless Dir.exist?(dir)
  
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
