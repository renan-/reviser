require 'rubygems'
require 'zip'
require_relative 'extractor'

# ZIP Extractor
# This extractor extract only zip archives.
class ZipExtractor < Extractor

	def initialize(archive,path_dir)
		super(archive, path_dir,'zip')
		Zip.continue_on_exists_proc = true
	end

	def extract 
		Zip::File.open(@src) do |zip_file|
  			zip_file.each do |entry|
  				path = File.join(@destination, entry.name)
    			entry.extract(path)
    			content = entry.get_input_stream.read
  			end
		end
	end

end

