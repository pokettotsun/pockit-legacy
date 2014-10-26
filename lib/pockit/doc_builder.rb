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
      File.open(path) do |file|
        write_modpack_info(file)
      end
    end
    
    # Writes the start of the documentation that contains the modpack information
    # @param file [File] File to write to
    # @return [null]
    def write_modpack_info (file)
      file.puts @modpack.name
      file.puts '=' * @modpack.name.length
      file.puts
      
      file.puts "A modpack by #{@modpack.author.to_sentence}"
    end
    
    private :write_modpack_info
    
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
