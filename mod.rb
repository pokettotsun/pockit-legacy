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
  
  # Additional notes about the mod, such as tweaks
  attr_reader :notes
  
  # Indicates whether the mod is a coremod
  attr_reader :core?
end

