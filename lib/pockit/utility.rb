require 'uri'
require 'open-uri'

module Pockit
  
  module Utility
    
    # Extracts the filename from a URL
    # @param url [String] URL of the file
    # @return [String] Filename pulled from the URL
    def url_filename (url)
      uri = URI.parse(url)
      File.basename(uri.path)
    end
    
    # Downloads the contents at a URL into a destination directory
    # @param url  [String] URL of the file
    # @param dest [String] Destination directory to save the file in
    # @return [null]
    def download (url, dest)
      wrap_download(url, dest) { |uri| open(uri).read }
    end
    
    # Downloads the contents at a URL that require authentication into a destination directory
    # @param url  [String] URL of the file
    # @param dest [String] Destination directory to save the file in
    # @param user [String] HTTP basic authentication username
    # @param pass [String] HTTP basic authentication password
    # @return [null]
    def download_auth (url, dest, user, pass)
      wrap_download(url, dest) { |uri| open(uri, :http_basic_authentication => [user, pass]).read }
    end
    
    # Sets up the output file to write content to it from a URL
    # @url [String] URL of the file
    # @dest [String] Destination directory to save the file in
    # @block Block returning the contents of the URL
    # @return [String] Path to the output file
    def wrap_download (url, dest, &block)
      filename = url_filename(url)
      filepath = File.join(dest, filename)
      
      begin
        File.open(filepath, 'wb') do |file|
          file.write block.call(url)
        end
      rescue Exception => e
        puts "Download failed #{url} => #{filepath} - do you need authentication?"
        File.delete(filepath) if File.exist?(filepath)
        raise e
      end
      
      filepath
    end
    
    # Extracts the contents of a zip or jar file to another directory
    # @param zip_file         [String] Path to the zip or jar file to extract
    # @param output_directory [String] Path to the directory to extract the files to
    # @return [null]
    def unzip (zip_file, output_directory)
      system('unzip', '-qq', '-o', '-d', output_directory, zip_file) or raise "Unzip failed for #{zip_file}"
    end
    
    # Retrieves a list of files in a zip or jar
    # @param path [String] Path to the package to inspect
    # @return [Array<String>] List of package contents
    def list_package_contents (path)
      output = `unzip -l '#{path}'`
      lines  = output.split(/[\r\n]+/)
      lines.shift # Archive:  pkg/bspkrs-core-1.7.10.zip
      lines.shift #   Length      Date    Time    Name
      lines.shift # ---------  ---------- -----   ----
      lines.pop   # ---------                     -------
      lines.pop   #  42822195                     13 files
      
      # 2740674  2014-10-19 00:48   bin/modpack.jar
      #    0          1       2           3
      lines.map { |line| line.strip.split(/\s+/)[3] }
    end
    
  end

end
