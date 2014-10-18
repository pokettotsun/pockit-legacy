module Pockit
  
  # Creates zip and jar packages
  class Package
    
    # Creates a new package instance
    # @param target [String] Path to the package file to create (with the extension)
    def initialize (target)
      @target   = target
      @contents = []
    end
    
    # Adds a file, directory, or path pattern to the package
    # @param path  [String] File, directory, or path pattern
    # @return [null]
    def add (path)
      @contents << path
    end
    
    # Creates the package
    # @return [null]
    def create
      return if @contents.length <= 0
      File.delete(@target) if File.exist?(@target)
      
      files    = file_list
      sizes    = file_sizes(files)
      zip_args = ['-q', '-g', @target]
      
      progress = 0
      files.zip(sizes).each do |file, size|
        percent     = (progress / size.to_f * 100).round(0)
        percent_str = sprintf('%3d', percent)
        puts "[#{percent_str}%] #{file}"
        system('zip', *zip_args, file) or raise 'zip failed'
        progress += size
      end
    end
    
    # Generates the complete list of files to include in the package
    # @return [Array<String>] List of files
    def file_list
      files = []
      @contents.each do |path|
        if File.exist?(path) # path is a file
          files << path
        elsif Dir.exist?(path) # path is a directory
          add_directory(path, files)
        else # path is a glob pattern
          add_glob(path, files)
        end
      end
      files
    end
    
    # Recursively adds the contents of a directory to a file list
    # @param path  [String]        Directory path
    # @param files [Array<String>] File list to append to
    # @return [null]
    def add_directory (path, files)
      Dir.entries(path).each do |entry|
        next if entry.start_with?('.')
        entry_path = File.join(path, entry)
        add_entry(entry_path, files)
      end
    end
    
    # Adds files matching a glob pattern
    # @param pattern [String]        Glob pattern
    # @param files   [Array<String>] File list to append to
    def add_glob (pattern, files)
      Dir.glob(pattern).each do |entry|
        next if entry.start_with?('.')
        add_entry(entry, files)
      end
    end
    
    # Adds a file or directory to a file list
    # @param path  [String]        File or directory path
    # @param files [Array<String>] File list to append to
    # @return [null]
    def add_entry (path, files)
      if File.stat(entry_path).file? # entry is a file
        files << entry_path
      elsif File.stat(entry_path).directory? # entry is a directory
        add_directory(entry_path, files)
      end
    end
    
    # Retrieves the size of a set of files
    # @param files [Array<String>] List of file names
    # @return [Array<Fixnum>] Number of bytes for each file
    def file_sizes (files)
      files.map { |file| File.stat(file).size }
    end
    
    private :file_list, :add_directory, :add_glob
    
  end
  
end
