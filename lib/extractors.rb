require 'rubygems'
require 'zip'

# The module contains all methods to uncompress a archive 
# regardless the format.
#
# To add a new format, maybe you need to install the Gem.
# Find a Gem which uncompress a specified format on rubygems.org.
# Add the line "gem <gem>" in the Gemfile and execute "bundle install"
# Next, you have to require the gem: "require <gem>" in the header of this file.
#
# Now, you can right the method corresponding to the format.
# The name of the method corresponds to the format.
# For example, if you to use rar format, the name of the method will be: "rar"
# the header of method looks like the following block:
#
#  		def <format> (src, destination)
# 			...
# 		end
#
module Extractors

	# Method which unzip a file.
	# ZIP format
	def zip (src, destination)
		# Config the gem
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