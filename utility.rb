require 'uri'
require 'open-uri'

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
  wrap_download(url, dest) {|url| open(url).read}
end

# Downloads the contents at a URL that require authentication into a destination directory
# @param url  [String] URL of the file
# @param dest [String] Destination directory to save the file in
# @param user [String] HTTP basic authentication username
# @param pass [String] HTTP basic authentication password
# @return [null]
def download_auth (url, dest, user, pass)
  wrap_download(url, dest) {|url| open(url, :http_basic_authentication => [user, pass]).read}
end

# Sets up the output file to write content to it from a URL
# @url [String] URL of the file
# @dest [String] Destination directory to save the file in
# @block Block returning the contents of the URL
# @return [null]
def wrap_download (url, dest, &block)
  filename = url_filename(url)
  filepath = "#{dest}/#{filename}"
  File.open(filepath, 'wb') do |file|
    file.write block.call(url)
  end
end

# Creates a zip file from files matching filters
# @param zip_file [String]        Path to the zip file to create
# @param filters  [Array<String>] Set of file filters
# @return [null]
def zip (zip_file, *filters)
  filters.each do |filter|
    Dir.glob(filter).each do |filepath|
      system('zip', '-g', zip_file, filepath)
    end
  end
end

