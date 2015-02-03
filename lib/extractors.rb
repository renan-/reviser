require 'rubygems'
require 'rubygems/package'
require 'zip'
require 'zlib'
require 'seven_zip_ruby'
require 'fileutils'
require 'shellwords'

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
		# Cfg the gem
		Zip.on_exists_proc = true
		Zip.continue_on_exists_proc = true

		Zip::File.open(src) do |zip_file|
			#Entry = file or directory
	  		zip_file.each do |entry|
  				#Create filepath
 				filepath = File.join(destination, entry.name)
	  			# Check if it doesn't exist because of directories (overwrite)
				unless File.exist?(filepath)
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

	# Alias for format shortcut
	## cc Dominique Colnet
	alias :tgz :gz 
    
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

 	#
 	# Uncompress rar format
 	# if it is possible.
 	#
	def rar(src,destination)
 		`which unrar`
 		if $?.success?
 			src = Shellwords.escape(src)
 			destination = Shellwords.escape(destination)
 			`unrar e #{src} #{destination}`
		else
			puts 'Please install unrar : sudo apt-get install unrar'
		end
	end

	#
	# Uncompress a 7zip file
	#
	def seven_zip(src, destination) 
		File.open(src, 'rb') do |file|
  			SevenZipRuby::Reader.open(file) do |szr|
    			szr.extract_all destination
  			end
		end
	end

	#
	# Tip for call 7zip method 
	#
	def method_missing(m, *args, &block)  
    	if (ext = File.extname(args[0]).delete('.') == '7z')
    		seven_zip(args[0], args[1])
    	else 
    		raise "Format '#{ext.delete('.')}' not supported"
    	end
  	end


end