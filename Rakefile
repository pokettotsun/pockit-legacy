require 'rake'
require_relative 'lib/pockit/modpack'
require_relative 'lib/pockit/package'
require_relative 'lib/pockit/utility'

PACKAGE_DIRECTORY           = 'pkg'
PACKAGE_MODS_DIRECTORY      = File.join(PACKAGE_DIRECTORY, 'mods')
PACKAGE_COREMODS_DIRECTORY  = File.join(PACKAGE_DIRECTORY, 'coremods')
JAR_PATCH_CLIENT_DIR        = File.join(PACKAGE_DIRECTORY, 'modpack_client_jar')
JAR_PATCH_CLIENT_PACKAGE    = File.join(PACKAGE_DIRECTORY, 'bin', 'modpack.jar')
JAR_PATCH_SERVER_DIR        = File.join(PACKAGE_DIRECTORY, 'modpack_server_jar')
JAR_PATCH_SERVER_PACKAGE    = File.join(PACKAGE_DIRECTORY, 'bin', 'modpack.jar')
LINUX_SERVER_START_SCRIPT   = 'start.sh'
WINDOWS_SERVER_START_SCRIPT = 'start.bat'

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
  package_file = "#{modpack.name}-#{modpack.version}_#{modpack.mc_version}-client.zip"
  
  jar_patches, content = [], []
  package = Pockit::Package.new(package_file)
  modpack.client_mods.each do |mod|
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
  if !jar_patches.empty?
    package_client_jar_patch(jar_patches)
    package.add(JAR_PATCH_CLIENT_PACKAGE, PACKAGE_DIRECTORY)
  end
  
  # Add content manually to package
  if !content.empty?
    puts 'Extracting custom client content'
    count  = content.length
    done   = 1
    length = count.to_s.length * 2 + 1 # count size, /, done size
    format = "%#{length}s"
    content.each do |entry|
      mod, path = *entry
      progress = sprintf(format, "#{done}/#{count}")
      puts "[#{progress}] #{mod.name}: #{mod.url}"
      list_package_contents(path).each do |file|
        package_file = File.join(PACKAGE_DIRECTORY, file)
        package.add(package_file, PACKAGE_DIRECTORY)
      end
      system('unzip', '-qq', '-o', '-d', PACKAGE_DIRECTORY, path) or raise "unzip #{path} failed"
      done += 1
    end
  end
  
  puts "Creating client package #{package_file}"
  package.create
end

# Creates the modpack.jar needed to patch minecraft.jar for the client
# @param patches [Array<Pockit::Mod>] Set of mod patches
# @return [null]
def package_client_jar_patch (patches)
  puts "Creating client modpack.jar"
  package = Pockit::Package.new(JAR_PATCH_CLIENT_PACKAGE)
  
  # Unzip all patches
  patches.each do |mod|
    path = mod_download_location(mod)
    system('unzip', '-qq', '-o', '-d', JAR_PATCH_CLIENT_DIR, path) or raise "unzip #{path} failed"
  end
  
  # Create the patch jar
  package.add("#{JAR_PATCH_CLIENT_DIR}/**/*", JAR_PATCH_CLIENT_DIR)
  package.create
end

# Packages the files needed for the server
# @param modpack [Pockit::Modpack]
def package_server (modpack)
  package_file = "#{modpack.name}-#{modpack.version}_#{modpack.mc_version}-server.zip"
  
  jar_patches, content = [], []
  package = Pockit::Package.new(package_file)
  modpack.server_mods.each do |mod|
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
  if !jar_patches.empty?
    package_server_jar_patch(jar_patches)
    package.add(JAR_PATCH_SERVER_PACKAGE, PACKAGE_DIRECTORY)
  end
  
  # Add content manually to package
  if !content.empty?
    puts 'Extracting custom server content'
    count  = content.length
    done   = 1
    length = count.to_s.length * 2 + 1 # count size, /, done size
    format = "%#{length}s"
    content.each do |entry|
      mod, path = *entry
      progress = sprintf(format, "#{done}/#{count}")
      puts "[#{progress}] #{mod.name}: #{mod.url}"
      list_package_contents(path).each do |file|
        package_file = File.join(PACKAGE_DIRECTORY, file)
        package.add(package_file, PACKAGE_DIRECTORY)
      end
      system('unzip', '-qq', '-o', '-d', PACKAGE_DIRECTORY, path) or raise "unzip #{path} failed"
      done += 1
    end
  end
  
  # Add startup scripts
  package.add(LINUX_SERVER_START_SCRIPT)
  package.add(WINDOWS_SERVER_START_SCRIPT)
  
  puts "Creating server package #{package_file}"
  package.create
end

# Creates the modpack.jar needed to patch minecraft.jar for the server
# @param patches [Array<Pockit::Mod>] Set of mod patches
# @return [null]
def package_server_jar_patch (patches)
  puts "Creating server modpack.jar"
  package = Pockit::Package.new(JAR_PATCH_SERVER_PACKAGE)
  
  # Unzip all patches
  patches.each do |mod|
    path = mod_download_location(mod)
    system('unzip', '-qq', '-o', '-d', JAR_PATCH_SERVER_DIR, path) or raise "unzip #{path} failed"
  end
  
  # Create the patch jar
  package.add("#{JAR_PATCH_SERVER_DIR}/**/*", JAR_PATCH_SERVER_DIR)
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
  return if File.exist?(dest) # Already downloaded, don't need to download again
  
  dir = File.dirname(dest)
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
  when :core    then PACKAGE_COREMODS_DIRECTORY
  when :content then PACKAGE_DIRECTORY
  else               PACKAGE_MODS_DIRECTORY
  end
  File.join(dir, file)
end

# Retrieves a list of files in a zip or jar
# @param path [String] Path to the package to inspect
# @return [Array<String>] List of package contents
def list_package_contents (path)
  output = `unzip -l '#{path}'`
  lines  = output.split(/[\r\n]+/)
  lines.shift #   Length      Date    Time    Name
  lines.shift # ---------  ---------- -----   ----
  lines.pop   # ---------                     -------
  lines.pop   #  42822195                     13 files
  
  # 2740674  2014-10-19 00:48   bin/modpack.jar
  #    0          1       2           3
  lines.map { |line| line.strip.split(/\s+/)[3] }
end

# Checks whether HTTP authentication is provided
# @return [Boolean]
def http_auth
  ENV['http_user'] and ENV['http_pass']
end
