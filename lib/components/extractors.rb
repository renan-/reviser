require 'rubygems'
require 'fileutils'

module Reviser
	module Components

		# The module contains all methods to extract an archive
		# regardless the format.
		#
		# Convention over configuration !
		#
		# To add a new format, maybe you need to install the a gem.
		# Find your  gem which uncompress a specified format on rubygems.org.
		# Add the line "gem <gem>" in the Gemfile and execute "bundle install"
		#
		# Now, you can write the method corresponding to the format.
		# The name of the method corresponds to the format.
		# For example, if you want to use 'rar' format, the name of the method will be: "rar"
		# Don't forget to require the gem: "require <gem>" at the beginning of the method!
		# the header of method looks like the following block:
		#
		#  		def <format> (archive, destination)		require <gem> 	...		end
		#
		#
		#
		# @author 	Anthony Cerf
		# @author 	Yann Prono
		#
		module Extractors	

			# Method which unzips a file.
			# @param zip_file 		[String] the zip file.
			# @param destination 	[String] Destination of extracted data.
			def zip zip_file, destination
				require 'zip'
				# Cfg the gem
				Zip.on_exists_proc = true
				Zip.continue_on_exists_proc = true

				Zip::File.open(zip_file) do |archive|
					#Entry = file or directory
					archive.each do |entry|
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
			
			# Method which ungz a file.
			# @param gz_file 		[String] the gz file.
			# @param destination 	[String] Destination of extracted data.
			def gz gz_file, destination
				require 'zlib'
				file = Zlib::GzipReader.open(gz_file)
				unzipped = StringIO.new(file.read)
				file.close
				tar(unzipped, destination)
			end

			# Alias for format shortcut
			# CC Dominique Colnet!
			alias :tgz :gz 
		    
		    # Method which untar a tarfile.
			# @param tar_file 		[String] the tar file.
			# @param destination 	[String] Destination of extracted data.
			def tar tar_file, destination
				require 'rubygems/package'
		    	# test if src is String (filename) or IO stream
				if tar_file.is_a? String
					stream = File.open(tar_file)
				else
					stream = tar_file
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
			     		tarfile.close unless tarfile.closed?
			  		end
			  		tar.close
		  		end
		  		stream.close
			end

			# Method which unrar a rar file, if it is possible (proprietary format grr ...)
			# @param rar_file 		[String] the rar file.
			# @param destination 	[String] Destination of extracted data.
			def rar rar_file, destination
				require 'shellwords'
		 		`which unrar`
		 		if $?.success?
		 			src = Shellwords.escape(rar_file)
		 			destination = Shellwords.escape(destination)
		 			`unrar e #{src} #{destination}`
				else
					puts 'Please install unrar : sudo apt-get install unrar'
				end
			end

			# Method which un7zip a 7zip file.
			# @param seven_zip_file	[String] the 7zip file.
			# @param destination 	[String] Destination of extracted data.
			def seven_zip seven_zip_file, destination
				require 'seven_zip_ruby'
				File.open(seven_zip_file, 'rb') do |file|
		  			SevenZipRuby::Reader.open(file) do |szr|
		    			szr.extract_all destination
		  			end
				end
			end

			# Use first of all for seven zip format (little tip, can't call it directly).
			def method_missing(m, *args, &block)
		    	if (ext = File.extname(args[0]).delete('.') == '7z')
		    		seven_zip(args[0], args[1])
		    	else 
		    		raise "Format '#{ext.delete('.')}' not supported"
		    	end
		  	end

		end
	end
end