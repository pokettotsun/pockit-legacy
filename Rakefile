require 'rake'
require 'rake/clean'
require_relative 'lib/pockit/modpack'
require_relative 'lib/pockit/package'
require_relative 'lib/pockit/utility'

TEMP_DIRECTORY             = 'tmp'
PACKAGE_DIRECTORY          = 'pkg'
PACKAGE_MODS_DIRECTORY     = File.join(PACKAGE_DIRECTORY, 'mods')
PACKAGE_COREMODS_DIRECTORY = File.join(PACKAGE_DIRECTORY, 'coremods')

task :default => ['client']

desc 'Builds the client modpack'
task :client do
  modpack = find_modpack
  puts "Building #{modpack.name} v#{modpack.version} for Minecraft #{modpack.mc_version}"
  
  download_list(modpack.client_mods)
  package_client(modpack)
end

# Attempts to find a modpack to build
# @return [Pockit::Modpack]
def find_modpack
  file = Dir.glob('*.modpack').first
  raise 'No modpack found to build' unless file
  Pockit::Modpack.load(file)
end

# Packages the files needed for the client
# @param modpack [Pockit::Modpack]
def package_client (modpack)
  package_file = "#{modpack.name}-#{modpack.version}_#{modpack.mc_version}-client.zip"
  puts "Creating client package #{package_file}"
  
  package = Pockit::Package.new(package_file)
  modpack.client_mods.each do |mod|
    path = mod_download_location(mod)
    package.add(path)
  end
  package.create
end

# Downloads all mods in a list
# @param modlist [Pockit::Modlist] List of mods to download
# @return [null]
def download_list (modlist)
  puts 'Downloading mods'
  count  = modlist.length
  done   = 1
  length = count.to_s.length * 2 + 1 # count size, /, done size
  format = "%#{length}s"
  modlist.each do |mod|
    progress = sprintf(format, "#{done}/#{count}")
    puts "[#{progress}] #{mod.name}: #{mod.url}"
    download_mod(mod)
    done += 1
  end
end

# Downloads a single mod
# @param mod [Pockit::Mod] Mod to download
# @return [null]
def download_mod (mod)
  dest = mod_download_location(mod)
  dir  = File.dirname(dest)
  FileUtils.mkpath(dir) unless Dir.exist?(dir)
  
  if http_auth
    Pockit::Utility.download_auth(mod.url, dir, ENV['http_user'], ENV['http_pass'])
  else
    Pockit::Utility.download(mod.url, dir)
  end
end

# Generates the filepath to use for a mod
# @param mod [Pockit::Mod]
# @return [String] Path to where the mod should be saved
def mod_download_location (mod)
  file = Pockit::Utility.url_filename(mod.url)
  dir  = case mod.type
  when :core then PACKAGE_COREMODS_DIRECTORY
  when :jar  then TEMP_DIRECTORY
  else            PACKAGE_MODS_DIRECTORY
  end
  File.join(dir, file)
end

# Checks whether HTTP authentication is provided
# @return [Boolean]
def http_auth
  ENV['http_user'] and ENV['http_pass']
end
