module Pockit
  
  # Generates documentation for the modpack in Markdown
  class DocBuilder
    
    # Creates the documentation builder
    # @param modpack [Pockit::Modpack] Modpack to build documentation for
    def initialize (modpack)
      @modpack = modpack
    end
    
    # Creates the documentation and saves it to a file
    # @param path [String] Path to the file to save to
    # @return [null]
    def create (path)
      File.open(path, 'w') do |file|
        write_modpack_info(file)
        write_mod_list(file)
      end
    end
    
    # Writes the start of the documentation that contains the modpack information
    # @param file [File] File to write to
    # @return [null]
    def write_modpack_info (file)
      mods = {}
      @modpack.client_mods.each { |mod| mods[mod.id] = 1 }
      @modpack.server_mods.each { |mod| mods[mod.id] = 1 }
      
      file.puts @modpack.name
      file.puts '=' * @modpack.name.length
      file.puts
      
      author_str = @modpack.author.is_a?(Array) ? @modpack.author.to_sentence : @modpack.author
      file.puts @modpack.description
      file.puts "A modpack by #{author_str} containing #{mods.length} mods"
      file.puts "Version #{@modpack.version} for Minecraft #{@modpack.mc_version}"
      file.puts @modpack.website if @modpack.website and @modpack.website.length > 0
      file.puts
      file.puts '-----'
      file.puts
    end
    
    # Writes the list of mods
    # @param file [File] File to write to
    # @return [null]
    def write_mod_list (file)
      file.puts 'Contents'
      file.puts '--------'
      file.puts
      
      # Mark each mod as being client-only, server-only, or both
      mods = {}
      @modpack.client_mods.each { |mod| mods[mod.id] = [:client, mod] }
      @modpack.server_mods.each { |mod| mods[mod.id] = (mods.key?(mod.id) ? [:both, mod] : [:server, mod]) }
      
      # Produce an entry for each mod
      order = mods.keys.sort
      order.each do |id|
        entry = mods[id]
        side, mod = *entry
        write_mod_entry(file, mod, side)
      end
    end
    
    # Writes information about a single mod
    # @param file [File]        File to write to
    # @param mod  [Pockit::Mod] Mod to produce output for
    # @param side [Symbol]      +:client+, +:server+, or +:both+
    # @return [null]
    def write_mod_entry (file, mod, side)
      file.puts "### #{mod.name}"
      
      case side
      when :client then file.puts '**Client only**'
      when :server then  file.puts '**Server only**'
      end
      
      author_str = mod.author.is_a?(Array) ? mod.author.to_sentence : mod.author
      file.puts "by #{author_str}"
      file.puts "Version #{mod.version} for Minecraft #{mod.mc_version}"
      file.puts mod.website if mod.website and mod.website.length > 0
      file.puts
      file.puts mod.description if mod.description and mod.description.length > 0
      file.puts "**Notes:** #{mod.notes}" if mod.notes and mod.notes.length > 0
      file.puts
    end
    
    private :write_modpack_info, :write_mod_list, :write_mod_entry
    
  end

end

class Array
  
  # Joins the elements of the array into an English sentence
  # @return [String]
  def to_sentence
    case length
      when 0
        ''
      when 1
        self[0].to_s.dup
      when 2
        "#{self[0]} and #{self[1]}"
      else
        "#{self[0...-1].join(', ')}, and #{self[-1]}"
    end
  end
  
end
