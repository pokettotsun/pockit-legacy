require 'json'

module Pockit
  
  # Information about a modpack and its contents
  class Modpack
    
    # Visible and friendly name of the modpack
    attr_reader :name
    
    # Brief description of the modpack
    attr_reader :description
    
    # Modpack version
    attr_reader :version
    
    # Version of Minecraft the modpack is for
    attr_reader :mc_version
    
    # Creator(s) of the modpack
    attr_reader :author
    
    # URL to the webpage or website for the modpack
    attr_reader :website
    
    # Creates a new modpack instance
    def initialize (name, description, version, mc_version, author, website)
      @name        = name
      @description = description
      @version     = version
      @mc_version  = mc_version
      @author      = author
      @website     = website
    end
    
    # Loads modpack information from a file
    # @param path [String] Path to the file to load from
    # @return [Pockit::Modpack]
    def self.load (path)
      json = File.read(path)
      data = JSON.parse(json)
      
      name        = data['name']
      description = data['description']
      version     = data['version']
      mc_version  = data['mc_version']
      author      = data['author']
      website     = data['website']
      Pockit::Modpack.new(name, description, version, mc_version, author, website)
    end
    
  end
  
end

