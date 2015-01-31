require 'fileutils'
require_relative 'extractor'
require_relative 'component'

#
# Manages uncompression of archive.
# The archive contains all computing projects.
#
# @example The simple way to extract a compressed file is : 
# 		Archiver.extract(myFile, myDirectory)
#
# @author	Yann Prono
#
class Archiver < Component

	attr_reader :src, :destination

	$rejected = ['.','..']
	
	# Get archive to use and the path directory.
	def initialize(data)
		super data

		@src = @cfg[:src]
		@destination = @cfg[:dest]
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
			FileUtils.mkdir destination, :mode => 0700
		end
	end
	
	#
	# Extract the file into the destination directory.
	# @param file_name [String] the name of the archive.
	# @param destination [String] the destination directory.
	#
	def self.extract(file_name, destination = '.')
		raise Errno::ENOENT unless File.exists?(file_name)
		ext = File.extname(file_name)
		ext = ext.delete '.'

		self::destination? destination

		Extractor.send(ext,file_name, destination)
	end

	#
	# Method which extract an archive
	# which contains all computing projects.
	# This method extract in first time the archive
	# and after all extracted files.
	# Options are for the moment options[:verbose]
	#
	def run
		$logger.subtitle 'First extraction ' if options[:verbose]
		# Extract the original archive
		Archiver.extract(@src, @destination)
		$logger.subtitle 'Extraction of sub archives' if options[:verbose]
		
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
				FileUtils.rm_rf(File.join(@destination,entry))
				extracted += 1

				$logger.log "extract #{file_name} to #{destination}" if options[:verbose]
			# In case of it can't extract 
  			rescue => e
  				$logger.log("Can't extract #{entry}: #{e.message}", true) if options[:verbose]
  			end
  		end
  		$logger.footer("[#{extracted}/#{entries.size}] projects are been uncompressed", true) if options[:verbose]
	end

end