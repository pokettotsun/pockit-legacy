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
    def initialize (name, description, version, mc_version, author, website, client_mods, server_mods)
      @name        = name
      @description = description
      @version     = version
      @mc_version  = mc_version
      @author      = author
      @website     = website
      @client_mods = client_mods
      @server_mods = server_mods
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
      client_mods = load_modlist(data['client_contents'])
      server_mods = load_modlist(data['server_contents'])
      Pockit::Modpack.new(name, description, version, mc_version, author, website, client_mods, server_mods)
    end
    
    # Retrieves a list of mod IDs from a modlist file
    # @param path [String] Path to the file to load from
    # @return [Array<String>] Collection of mod IDs
    def self.load_modlist (path)
      json = File.read(path)
      data = JSON.parse(json)
      data['mods'].to_a
    end
    
    private_class_method :load_modlist
    
  end
  
end

