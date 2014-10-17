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
      raise 'Not implemented'
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
    
  end
  
end

