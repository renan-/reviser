require 'fileutils'

require_relative 'extractors'

#
# Manages uncompression of archive.
# The archive contains all computing projects or anything archive.
#
# @example The simple way to extract a compressed file is : 
# 		Archiver.extract(myFile, myDirectory)
#
# @author	Yann Prono
#
module Components
	class Archiver < Component

		extend Extractors

		attr_reader :src, :destination

		# Ignored entries
		$rejected = ['.','..']
		
		# Get the archive name and the destination directory.
		def initialize(data)
			super data
			@src = Cfg[:src]
			@destination = Cfg[:dest]
		end

		#
		# Check if the directory destination exists.
		# else create it.
		# For the moment, if the directory exists, it is deleted (avoid conflicts) then created.
		# @param destination [String] the destination directory
		#
		def self.destination?(destination)
			unless $rejected.include? File.basename destination
				FileUtils.rm_rf(destination) if Dir.exists? destination
				FileUtils.mkdir_p destination, :mode => 0700
			end
		end
		
		#
		# Extract the file into the destination directory.
		# @param file_name [String] the name of the archive.
		# @param destination [String] the destination directory.
		#
		def self.extract(file_name, destination = '.')
			raise Errno::ENOENT unless File.exist? file_name
			ext = File.extname(file_name)
			ext = ext.delete '.'

			# Raise exception if the format is unknown by Archiver
			raise "Unknown format '#{r}'" unless respond_to?(ext)

			self::destination? destination

			send(ext,file_name, destination)
		end

		#
		# Method which extract an archive
		# which contains all computing projects.
		# This method extracts in first time the archive
		# and after all extracted files.
		# Options are for the moment options[:verbose]
		#
		def run
			@logger.h1 Logger::INFO,"First extraction - #{src}"
			# Extract the original archive
			Archiver.extract(@src, @destination)
			@logger.h1 Logger::INFO,'Extraction of sub archives'
			
			# Extract all sub archives
			entries = Dir.entries(@destination) - $rejected
			extracted = 0
			entries.each do |entry|
				ext = File.extname(entry)
				basename = File.basename(entry, ext)
				begin
					file_name = File.join(@destination,File.basename(entry))
					destination = File.join(@destination,basename)

	  				Archiver.extract(file_name, destination)
  					FileUtils.rm_rf(file_name)					
					extracted += 1

					@logger.h2 Logger::INFO, "extracting #{file_name} to #{destination}"
				# In case of it can't extract 
	  			rescue => e
	  				@logger.h2 Logger::ERROR, "Can't extract #{entry}: #{e.message}"
	  				FileUtils.rm_rf(File.join(@destination,entry))
	  				puts e
	  			end
	  		end
	  		@logger.h1 Logger::INFO, "[#{extracted}/#{entries.size}] projects have been processed"
		end

	end

end