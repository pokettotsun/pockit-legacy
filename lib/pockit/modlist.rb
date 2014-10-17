require 'json'

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

