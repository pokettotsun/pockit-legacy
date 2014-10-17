require 'json'

module Pockit
  
  # Information about a mod included in the pack
  class Mod
    
    # Unique ID of the mod
    attr_reader :id
    
    # Visible name of the mod
    attr_reader :name
    
    # Name and/or email of the mod creator
    attr_reader :author
    
    # Mod version
    attr_reader :version
    
    # Minecraft version the mod is compatible with
    attr_reader :mc_version
    
    # URL of zip or jar file download
    attr_reader :url
    
    # URL of information about the mod
    attr_reader :website
    
    # Additional notes about the mod, such as tweaks
    attr_reader :notes
    
    # Indicates the mod's type (:normal, :core, :jar)
    attr_reader :type
    
    # Indicates whether the mod is a coremod
    def coremod?
      return @type == :core
    end
    
    # Indicates whether the mod is a patch to minecraft.jar
    def jar_patch?
      return @type == :jar
    end
    
    # Create a new mod reference
    def initialize (id, name, author, version, mc_version, url, website, notes, type)
      @id         = id
      @name       = name
      @author     = author
      @version    = version
      @mc_version = mc_version
      @url        = url
      @notes      = notes
      @type       = type
    end
    
    # Loads mod information from a file
    # @param path [String] Path to the file to load from
    # @return [Mod]
    def self.load (path)
      json = File.read(path)
      data = JSON.parse(json)
      
      id         = data['id']
      name       = data['name']
      author     = data['author']
      version    = data['version']
      mc_version = data['mc_version']
      url        = data['url']
      website    = data['website']
      notes      = data['notes']
      type_str   = data['type']
      type = case type_str
      when 'core' then :core
      when 'jar'  then :jar
      else :normal
      end
      Mod.new(id, name, author, version, mc_version, url, website, notes, type)
    end

  end

end

