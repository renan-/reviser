require 'zip'

# The module contains all methods to uncompress a archive 
# regardless the format.
module Extractors

	# Method which unzip a file.
	def zip (src, destination)
		# Condig
		Zip.on_exists_proc = true
		Zip.continue_on_exists_proc = true

		Zip::File.open(src) do |zip_file|
			#Entry = file or directory
	  		zip_file.each do |entry|
  				#Create filepath
 				filepath = File.join(destination, entry.name)
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