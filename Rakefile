require 'rake'
require_relative 'lib/pockit/modpack'
require_relative 'lib/pockit/package'
require_relative 'lib/pockit/utility'
require_relative 'lib/pockit/doc_builder'

include Pockit::Utility

CONFIG_DIRECTORY            = 'config'
PACKAGE_DIRECTORY           = 'pkg'
PACKAGE_MODS_DIRECTORY      = File.join(PACKAGE_DIRECTORY, 'mods')
PACKAGE_COREMODS_DIRECTORY  = File.join(PACKAGE_DIRECTORY, 'coremods')
JAR_PATCH_CLIENT_DIR        = File.join(PACKAGE_DIRECTORY, 'modpack_client_jar')
JAR_PATCH_SERVER_DIR        = File.join(PACKAGE_DIRECTORY, 'modpack_server_jar')
JAR_PATCH_PACKAGE           = File.join(PACKAGE_DIRECTORY, 'bin', 'modpack.jar')
LINUX_SERVER_START_SCRIPT   = 'start.sh'
WINDOWS_SERVER_START_SCRIPT = 'start.bat'
EULA_FILE                   = 'eula.txt'

task :default => ['client', 'server']

desc 'Builds the client modpack'
task :client do
  modpack = find_modpack
  puts "Building #{modpack.name} v#{modpack.version} client for Minecraft #{modpack.mc_version}"
  
  download_list(modpack.client_mods)
  package_client(modpack)
end

desc 'Builds the server modpack'
task :server do
  modpack = find_modpack
  puts "Building #{modpack.name} v#{modpack.version} server for Minecraft #{modpack.mc_version}"
  
  download_list(modpack.server_mods)
  package_server(modpack)
end

desc 'Creates a markdown document containing information about the modpack'
task :doc do
  modpack     = find_modpack
  doc_file    = "#{modpack.name}.md"
  doc_builder = Pockit::DocBuilder.new(modpack)
  doc_builder.create(doc_file)
end

desc 'Cleans artifacts produced by the build'
task :clean do
  # Remove zip and jar files in top-level directory
  files = []
  files.concat(Dir.glob('*.jar'))
  files.concat(Dir.glob('*.zip'))
  files.each do |file|
    puts "- #{file}"
    File.delete(file)
  end
  
  # Remove package directory
  if Dir.exist?(PACKAGE_DIRECTORY)
    puts "- #{PACKAGE_DIRECTORY}/"
    FileUtils.rm_r(PACKAGE_DIRECTORY)
  end
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
  # Add the main contents to the package
  package_file = "#{modpack.name}-#{modpack.version}_#{modpack.mc_version}-client.zip"
  package      = prepare_package(package_file, modpack.client_mods, JAR_PATCH_CLIENT_DIR)
  
  puts "Creating client package #{package_file}"
  package.create
end

# Packages the files needed for the server
# @param modpack [Pockit::Modpack]
def package_server (modpack)
  # Add the main contents to the package
  package_file = "#{modpack.name}-#{modpack.version}_#{modpack.mc_version}-server.zip"
  package      = prepare_package(package_file, modpack.server_mods, JAR_PATCH_SERVER_DIR)
  
  # Add startup scripts and EULA
  package.add(LINUX_SERVER_START_SCRIPT)
  package.add(WINDOWS_SERVER_START_SCRIPT)
  package.add(EULA_FILE)
  
  puts "Creating server package #{package_file}"
  package.create
end

# Populates a +Pockit::Package+ instance with the contents from a mod list
# @param package_file [String]          Path to the package file to create
# @param modlist      [Pockit::Modlist] List of mods to add to the package
# @param patch_dir    [String]          Path to the directory to use for collecting patch files
# @return [Pockit::Package]
def prepare_package (package_file, modlist, patch_dir)
  # Sort through the different types of mods
  jar_patches, content = [], []
  package = Pockit::Package.new(package_file)
  modlist.each do |mod|
    path = mod_download_location(mod)
    if mod.jar_patch?
      # Jar patch has special process
      jar_patches << mod
    elsif mod.content?
      # Content is treated differently
      content << [mod, path]
    else
      package.add(path, PACKAGE_DIRECTORY)
    end
  end
  
  # Create modpack.jar to patch minecraft.jar
  unless jar_patches.empty?
    package_path = package_jar_patch(jar_patches, patch_dir)
    package.add(package_path, PACKAGE_DIRECTORY)
  end
  
  # Add content manually to package
  if !content.empty?
    puts 'Extracting custom content'
    count  = content.length
    done   = 1
    length = count.to_s.length * 2 + 1 # count size, /, done size
    format = "%#{length}s"
    content.each do |entry|
      mod, path = *entry
      progress = sprintf(format, "#{done}/#{count}")
      puts "[#{progress}] #{mod.name}: #{mod.url}"
      unzip(path, PACKAGE_DIRECTORY)
      list_package_contents(path).each do |entry|
        next if entry.end_with?('/') # Skip over directories, explicitly add files only
        file = File.join(PACKAGE_DIRECTORY, entry)
        package.add(file, PACKAGE_DIRECTORY)
      end
      done += 1
    end
  end
  
  package.add(CONFIG_DIRECTORY) if Dir.exist?(CONFIG_DIRECTORY) # Add custom configuration
  package
end

# Creates the modpack.jar needed to patch minecraft.jar
# @param patches   [Array<Pockit::Mod>] Set of mod patches
# @param patch_dir [String]             Path to the directory to use for collecting patch files
# @return [String] Path to modpack.jar
def package_jar_patch (patches, patch_dir)
  puts "Creating modpack.jar"
  package = Pockit::Package.new(JAR_PATCH_PACKAGE)
  
  # Unzip all patches
  patches.each do |mod|
    path = mod_download_location(mod)
    unzip(path, patch_dir)
  end
  
  # Create the patch jar
  package.add("#{patch_dir}/**/*", patch_dir)
  package.create
  
  JAR_PATCH_PACKAGE
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
  return if File.exist?(dest) # Already downloaded, don't need to download again
  
  dir = File.dirname(dest)
  FileUtils.mkpath(dir) unless Dir.exist?(dir)
  
  if http_auth
    download_auth(mod.url, dir, ENV['http_user'], ENV['http_pass'])
  else
    download(mod.url, dir)
  end
end

# Generates the filepath to use for a mod
# @param mod [Pockit::Mod]
# @return [String] Path to where the mod should be saved
def mod_download_location (mod)
  file = url_filename(mod.url)
  dir  = case mod.type
  when :core    then PACKAGE_COREMODS_DIRECTORY
  when :content then PACKAGE_DIRECTORY
  else               PACKAGE_MODS_DIRECTORY
  end
  File.join(dir, file)
end

# Checks whether HTTP authentication is provided
# @return [Boolean]
def http_auth
  ENV['http_user'] and ENV['http_pass']
end

