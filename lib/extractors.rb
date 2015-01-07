require 'rubygems'
require 'rubygems/package'
require 'zip'
require 'zlib'
require 'fileutils'

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
	

	#
	# Method which unzip a file.
	# ZIP format
	#
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
  				if !File.exist?(filepath)
  					# Create directories to access file
 					FileUtils.mkdir_p(File.dirname(filepath))
   					entry.extract(filepath) 
    			end
  			end
		end
	end
	
	#
	# Method which ungzip a file
	# gzip format
	#
	def gz (tarfile,destination)
      	z = Zlib::GzipReader.open(tarfile)
      	unzipped = StringIO.new(z.read)
      	z.close
      	tar(unzipped, destination)
    end
    
    #
	# Method which untar a file
	# tar format
	#
    def tar (src,destination)
    	# test if src is String (filename) or IO stream
    	if src.is_a? String
    		stream = File.open(src)
    	else
    		stream = src
    	end

    	Gem::Package::TarReader.new(stream) do |tar|
	        tar.each do |tarfile|
	          	destination_file = File.join destination, tarfile.full_name
	          	if tarfile.directory?
	            	FileUtils.mkdir_p destination_file
				else
		            destination_directory = File.dirname(destination_file)
		            FileUtils.mkdir_p destination_directory unless File.directory?(destination_directory)
		            File.open destination_file, 'wb' do |f|
		              	f.print tarfile.read
		          	end
	     		end
	  		end
  		end
 	end


end