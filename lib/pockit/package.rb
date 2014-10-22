module Pockit
  
  # Creates zip and jar packages
  class Package
    
    # Creates a new package instance
    # @param target [String] Path to the package file to create (with the extension)
    def initialize (target)
      @target   = target
      @contents = {}
    end
    
    # Adds a file, directory, or path pattern to the package
    # @param path  [String] File, directory, or path pattern
    # @param strip [String] Directory path to strip from the beginning of +path+ during creation
    # @return [null]
    def add (path, strip = nil)
      if strip
        strip += '/' unless strip.end_with?('/')
      else
        strip = nil
      end
      
      if Dir.exist?(path) or File.exist?(path)
        add_entry(path, strip)
      else
        add_glob(path, strip)
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
      
      sizes = file_sizes
      progress, total = 0, 0
      if verbose
        # Calculate total input size
        sizes.each_value { |size| total += size }
        total = total.to_f
      end
      
      @contents.each_pair do |src_file, strip|
        zip_file, dest_file = nil, nil
        if strip and !strip.empty?
          # Strip the beginning of the path off of the file by changing directories
          up_str    = '../' * strip.count('/')
          zip_file  = up_str + @target
          dest_file = src_file[strip.length, src_file.length - strip.length]
        else
          # Add the file from where it is
          zip_file  = @target
          dest_file = src_file
          strip     = nil
        end
        
        if verbose
          # Display percentage information
          file_size   = sizes[src_file]
          percent     = (progress / total * 100).round(0)
          percent_str = sprintf('%3d', percent)
          puts "[#{percent_str}%] #{src_file} => #{@target}:#{dest_file}"
          progress += file_size
        end
        
        zip(zip_file, dest_file, strip)
      end
    end
    
    # Adds a file to a zip archive
    # @param zip_file [String]       Path to the zip file
    # @param file     [String]       Path to the file to add
    # @param dir      [String, null] Directory to be in when zipping
    # @return [null]
    def zip (zip_file, file, dir = nil)
      zip_args = ['-q', '-g']
      pid = if dir
        spawn('zip', *zip_args, zip_file, file, :chdir => dir)
      else
        spawn('zip', *zip_args, zip_file, file)
      end
      Process.wait(pid) or raise 'Zip failed'
    end
    
    # Recursively adds the contents of a directory to a file list
    # @param path  [String] Directory path
    # @param strip [String] Path prefix to strip from zip files
    # @return [null]
    def add_directory (path, strip)
      Dir.entries(path).each do |entry|
        next if entry.start_with?('.')
        entry_path = File.join(path, entry)
        add_entry(entry_path, strip)
      end
    end
    
    # Adds files matching a glob pattern
    # @param pattern [String] Glob pattern
    # @param strip   [String] Path prefix to strip from zip files
    def add_glob (pattern, strip)
      Dir.glob(pattern).each do |entry|
        next if entry.start_with?('.')
        add_entry(entry, strip)
      end
    end
    
    # Adds a file or directory to a file list
    # @param path  [String] File or directory path
    # @param strip [String] Path prefix to strip from zip files
    # @return [null]
    def add_entry (path, strip)
      if File.stat(path).file? # entry is a file
        @contents[path] = strip
      elsif File.stat(path).directory? # entry is a directory
        add_directory(path, strip)
      end
    end
    
    # Retrieves the file sizes of each package entry
    # @return [Hash<String, Fixnum>] Mapping of filename to file size in bytes
    def file_sizes
      sizes = {}
      @contents.each_key.map do |file|
        size = File.stat(file).size
        sizes[file] = size
      end
      sizes
    end
    
    private :zip, :add_directory, :add_glob, :add_entry, :file_sizes
    
  end
  
end
