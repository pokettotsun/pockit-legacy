require 'json'
require_relative 'mod'

module Pockit
  
  # Stores a collection of mods each having the same Minecraft version
  class Modlist
    
    # Minecraft version each mod is compatible with
    attr_reader :mc_version
    
    # Creates a new modlist instance
    def initialize (mc_version, mod_ids)
      @mc_version = mc_version
      @mod_ids    = mod_ids
    end
    
    # Number of mods in the list
    # @return [Fixnum]
    def length
      @mod_ids.length
    end
    alias size length
    
    # Operates on each mod in the list
    def each (&block)
      @mod_ids.each do |id|
        if path = find_mod(id)
          mod = Pockit::Mod.load(path)
          block.call(mod)
        else
          puts "WARNING: Mod '#{id}' compatible with #{@mc_version} not found"
        end
      end
    end
    
    # Attempts to find a mod compatible with the pre-set Minecraft version
    # @param id [String] Mod ID
    # @return [String, null] Path to the mod file or +nil+ if the mod wasn't found
    def find_mod (id)
      version_path = File.join('mods', @mc_version)
      if Dir.exist?(version_path)
        quick_find_mod(version_path, id) or exhaustive_find_mod(version_path, id)
      else # Version directory doesn't exist
        nil
      end
    end
    
    # Attempts to quickly find a mod
    # @param path [String] Path to search
    # @param id   [String] Mod ID
    # @return [String, null] Path to the mod file or +nil+ if the mod wasn't found
    def quick_find_mod (path, id)
      filter = File.join(path, "#{id}_*.mod") # Match .mod files named by ID followed with version
      mod_entries = Dir.glob(filter).select do |entry|
        mod = Pockit::Mod.load(entry)
        mod.id == id
      end
      mod_entries.sort.last # Highest version of nil if empty
    end
    
    # Searches all mod files
    # @param path [String] Path to search
    # @param id   [String] Mod ID
    # @return [String, null] Path to the mod file or +nil+ if the mod wasn't found
    def exhaustive_find_mod (path, id)
      mod_entries = Dir.entries(path).select do |entry|
        if entry.end_with?('.mod') # Skip files not ending with .mod
          mod_path = File.join(path, entry)
          mod = Pockit::Mod.load(mod_path)
          mod.id == id
        else
          false
        end
      end
      mod_entries.sort.last # Highest version or nil if empty
    end
    
    # Loads modlist information from a file
    # @param path       [String] Path to the file to load from
    # @param mc_version [String] Minecraft version of each mod
    # @return [Pockit::Modlist]
    def self.load (path, mc_version)
      json = File.read(path)
      data = JSON.parse(json)
      
      mod_ids = data['mods'].to_a
      Pockit::Modpack.new(mc_version, mod_ids)
    end
    
    private :find_mod, :quick_find_mod, :exhaustive_find_mod
    
  end
  
end
