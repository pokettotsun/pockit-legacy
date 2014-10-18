require 'rake'
require 'rake/clean'
require_relative 'lib/pockit/modpack'
require_relative 'lib/pockit/package'
require_relative 'lib/pockit/utility'

PACKAGE_DIRECTORY          = 'pkg'
PACKAGE_MODS_DIRECTORY     = File.join(PACKAGE_DIRECTORY, 'mods')
PACKAGE_COREMODS_DIRECTORY = File.join(PACKAGE_DIRECTORY, 'coremods')
JAR_PATCH_CLIENT_DIR       = File.join(PACKAGE_DIRECTORY, 'modpack_client_jar')
JAR_PATCH_CLIENT_PACKAGE   = File.join(JAR_PATCH_CLIENT_DIR, 'modpack.jar')
JAR_PATCH_SERVER_DIR       = File.join(PACKAGE_DIRECTORY, 'modpack_server_jar')
JAR_PATCH_SERVER_PACKAGE   = File.join(JAR_PATCH_SERVER_DIR, 'modpack.jar')

CLEAN.include('*.zip')
CLEAN.include('*.jar')
CLEAN.include(PACKAGE_DIRECTORY)

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
  
  jar_patches = []
  package     = Pockit::Package.new(package_file)
  modpack.client_mods.each do |mod|
    if mod.jar_patch?
      # Jar patch has special process
      jar_patches << mod
    else
      path = mod_download_location(mod)
      package.add(path, PACKAGE_DIRECTORY)
    end
  end
  
  # Create modpack.jar to patch minecraft.jar
  if !jar_patches.empty?
    package_client_jar_patch(jar_patches)
    package.add(JAR_PATCH_CLIENT_PACKAGE, JAR_PATCH_CLIENT_DIR)
  end
  
  puts "Creating client package #{package_file}"
  package.create
end

# Creates the modpack.jar needed to patch minecraft.jar for the client
# @param patches [Array<Pockit::Mod>] Set of mod patches
# @return [null]
def package_client_jar_patch (patches)
  package = Pockit::Package.new(JAR_PATCH_CLIENT_PACKAGE)
  puts "Creating client modpack.jar"
  
  # Unzip all patches
  patches.each do |mod|
    path = mod_download_location(mod)
    system('unzip', '-qq', '-o', '-d', JAR_PATCH_CLIENT_DIR, path) or raise "unzip #{path} failed"
  end
  
  # Create the patch jar
  package.add("#{JAR_PATCH_CLIENT_DIR}/**/*")
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
  else            PACKAGE_MODS_DIRECTORY
  end
  File.join(dir, file)
end

# Checks whether HTTP authentication is provided
# @return [Boolean]
def http_auth
  ENV['http_user'] and ENV['http_pass']
end
