module Pockit
  
  # Creates zip and jar packages
  class Package
    
    # Creates a new package instance
    # @param target [String] Path to the package file to create (with the extension)
    def initialize (target)
      @target   = target
      @contents = []
      @strip    = []
    end
    
    # Adds a file, directory, or path pattern to the package
    # @param path  [String] File, directory, or path pattern
    # @param strip [String] Directory path to strip from the beginning of +path+ during creation
    # @return [null]
    def add (path, strip = nil)
      @contents << path
      if strip
        @strip << (strip.end_with?('/') ? strip : strip + '/')
      else
        @strip << nil
      end
    end
    
    # Creates the package
    # @param verbose [Boolean] Flag indicating whether verbosity is turned on
    # @return [null]
    def create (verbose = true)
      return if @contents.length <= 0
      File.delete(@target) if File.exist?(@target)
      dir = File.dirname(@target)
      FileUtils.mkpath(dir) unless Dir.exist?(dir)
      
      files    = file_list
      sizes    = file_sizes(files)
      zip_args = ['-q', '-g']
      
      progress, total = 0, 0
      sizes.each { |size| total += size }
      total = total.to_f
      files.zip(sizes).each do |entry, size|
        file, strip = *entry
        if verbose
          percent     = (progress / total * 100).round(0)
          percent_str = sprintf('%3d', percent)
          puts "[#{percent_str}%] #{file}"
        end
        
        pid = if strip and strip.length > 0
          up_str   = '../' * strip.count('/')
          zip_file = up_str + @target
          rel_file = file[strip.length, file.length - strip.length]
          spawn('zip', *zip_args, zip_file, rel_file, :chdir => strip)
        else
          spawn('zip', *zip_args, @target, file) or raise 'zip failed'
        end
        Process.wait(pid) or raise 'zip failed'
        
        progress += size
      end
    end
    
    # Generates the complete list of files to include in the package
    # @return [Array<Array<String>>] List of files
    def file_list
      files = []
      @contents.zip(@strip).each do |path, strip|
        if File.exist?(path) # path is a file
          files << [path, strip]
        elsif Dir.exist?(path) # path is a directory
          add_directory(path, strip, files)
        else # path is a glob pattern
          add_glob(path, strip, files)
        end
      end
      files
    end
    
    # Recursively adds the contents of a directory to a file list
    # @param path  [String]               Directory path
    # @param strip [String]               Path prefix to strip from zip files
    # @param files [Array<Array<String>>] File list to append to
    # @return [null]
    def add_directory (path, strip, files)
      Dir.entries(path).each do |entry|
        next if entry.start_with?('.')
        entry_path = File.join(path, entry)
        add_entry(entry_path, strip, files)
      end
    end
    
    # Adds files matching a glob pattern
    # @param pattern [String]               Glob pattern
    # @param strip   [String]               Path prefix to strip from zip files
    # @param files   [Array<Array<String>>] File list to append to
    def add_glob (pattern, strip, files)
      Dir.glob(pattern).each do |entry|
        next if entry.start_with?('.')
        add_entry(entry, strip, files)
      end
    end
    
    # Adds a file or directory to a file list
    # @param path  [String]               File or directory path
    # @param strip [String]               Path prefix to strip from zip files
    # @param files [Array<Array<String>>] File list to append to
    # @return [null]
    def add_entry (path, strip, files)
      if File.stat(path).file? # entry is a file
        files << [path, strip]
      elsif File.stat(path).directory? # entry is a directory
        add_directory(path, strip, files)
      end
    end
    
    # Retrieves the size of a set of files
    # @param files [Array<Array<String>>] List of file names
    # @return [Array<Fixnum>] Number of bytes for each file
    def file_sizes (files)
      files.map { |entry| File.stat(entry[0]).size }
    end
    
    private :file_list, :add_directory, :add_glob
    
  end
  
end
