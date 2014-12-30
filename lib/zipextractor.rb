require 'rubygems'
require 'zip'
require_relative 'extractor'

# ZIP Extractor
# This extractor extract only zip archives.
class ZipExtractor < Extractor

	def initialize(archive,path_dir)
		super(archive, path_dir,'zip')
		Zip.on_exists_proc = true
		Zip.continue_on_exists_proc = true
	end

	def extract 
		super
		# Open file
		Zip::File.open(@src) do |zip_file|
			#Entry = file or directory
  			zip_file.each do |entry|
  				#Create filepath
  				filepath = File.join(@destination, entry.name)
  				# Check if it doesn't exist because of directories (overwrite)
  				if(!File.exist?(filepath))
  					# Create directories to access file
  					FileUtils.mkdir_p(File.dirname(filepath))
    				entry.extract(filepath) 
    			end
  			end
		end
	end

end

