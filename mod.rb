require 'json'

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
  
  # Indicates whether the mod is a coremod
  attr_reader :core
  
  # Create a new mod reference
  def initialize (id, name, author, version, mc_version, url, website, notes, core)
    @id         = id
    @name       = name
    @author     = author
    @version    = version
    @mc_version = mc_version
    @url        = url
    @notes      = notes
    @core       = core
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
    core       = data['core'] != 0 ? true : false
    Mod.new(id, name, author, version, mc_version, url, website, notes, core)
  end
end

