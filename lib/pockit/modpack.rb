require 'json'
require_relative 'modlist'

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
    
    # Collection of mods present in the client package
    # @return [Pockit::Modlist]
    attr_reader :client_mods
    
    # Collection of mods present in the server package
    # @return [Pockit::Modlist]
    attr_reader :server_mods
    
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
      client_mods = Pockit::Modlist.load(data['client_contents'], mc_version)
      server_mods = Pockit::Modlist.load(data['server_contents'], mc_version)
      Pockit::Modpack.new(name, description, version, mc_version, author, website, client_mods, server_mods)
    end
    
  end
  
end
