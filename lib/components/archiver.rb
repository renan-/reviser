require 'fileutils'
require_relative 'extractors'

module Components

	# Manages uncompression of archive.
	# Archiver extracts all data in a given compressed file.
	#
	# In case of the University of Lorraine,
	# the archive contains all computing projects, compressed too.
	#
	# @example The simple way to extract a compressed file is :
	#		Archiver.extract(myFile, myDirectory)
	#
	# @author	Yann Prono
	#
	class Archiver < Component

		# methods for each different archive format
		extend Extractors

		# Ignored entries
		$rejected = ['.','..']
		
		# Initialize archive file and the directory of destination.
		def initialize(data)
			super data
			@src = Cfg[:src]
			@destination = Cfg[:dest]
		end


		# Check if the directory destination exists.
		# else create it.
		# For the moment, if the directory exists // TODO little input to confirm
		# @param destination [String] the destination directory
		#
		def self.destination?(destination)
			unless $rejected.include? File.basename destination
				FileUtils.rm_rf(destination) if Dir.exists? destination
				FileUtils.mkdir_p destination, :mode => 0700
			end
		end
		

		# Extract the archive into the destination directory.
		# @param file_name 		[String] The name of the archive.
		# @param destination 	[String] The destination directory.
		#
		def self.extract(file_name, destination = '.')
			raise Errno::ENOENT unless File.exist? file_name

			# Get extension of file_name to know which method calls
			ext = File.extname(file_name)
			ext = ext.delete('.')

			# Raise exception if the format is unknown by Archiver
			raise "Unknown format '#{r}'" unless respond_to?(ext)
			# Check if destination exists
			self::destination? destination

			# Run extraction!
			send(ext,file_name, destination)
		end


		# Method which extract an archive
		# which contains all computing projects.
		#
		# This method extracts,in first time,the archive
		# given in the constructor and after, all extracted files.
		#
		# Use this method in a global usage of Reviser!
		# Options are for the moment :verbose
		#
		def run
			@logger.h1 Logger::INFO,"First extraction - #{@src}"
			# Extract the original archive
			Archiver.extract(@src, @destination)

			@logger.h1 Logger::INFO,'Extraction of sub archives'
			
			# Extract all sub archives
			entries = Dir.entries(@destination) - $rejected
			extracted = 0

			entries.each do |entry|

				ext = File.extname entry
				basename = File.basename entry, ext
				begin
					file_name = File.join(@destination,File.basename(entry))
					destination = File.join(@destination,basename)

					# Run extraction!
	  				Archiver.extract(file_name, destination)
					extracted += 1
					@logger.h2 Logger::INFO, "extracting #{file_name} to #{destination}"

				# In case of it can't extract the file
	  			rescue => e
	  				@logger.h2 Logger::ERROR, "Can't extract #{entry}: #{e.message}"
	  			end
				# Delete in all case the archive (useless after this step)
				FileUtils.rm_rf file_name
	  		end
	  		@logger.h1 Logger::INFO, "[#{extracted}/#{entries.size}] projects have been processed"
		end

	end
end