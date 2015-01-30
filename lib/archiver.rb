require 'fileutils'
require_relative 'extractor'
require_relative 'component'
require_relative 'generator_log'

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

	# Logger of the archiver
	$logger

	$rejected = ['.','..']

	
	# Get archive to use and the path directory.
	def initialize(data)
		super data

		@src = @cfg[:src]
		@destination = @cfg[:dest]
		$logger = GeneratorLog.new('archiver.txt')
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

		$logger.log "extract #{file_name} to #{destination}" if $logger
	end

	#
	# Method which extract an archive
	# which contains all computing projects.
	# This method extract in first time the archive
	# and after all extracted files.
	#
	def run
		$logger.title "#{Archiver.name}"

		$logger.subtitle 'First extraction '
		# Extract the original archive
		Archiver.extract(@src, @destination)
		$logger.subtitle 'Extraction of sub archives'
		
		# Extract all sub archives
		entries = Dir.entries(@destination) - $rejected
		extracted = 0
		entries.each do |entry|
			ext = File.extname(entry)
			basename = File.basename(entry, ext)
			begin
  				Archiver.extract(File.join(@destination,File.basename(entry)), File.join(@destination,basename))
				FileUtils.rm_rf(File.join(@destination,entry))
				extracted += 1

			# In case of it can't extract 
  			rescue => e
  				$logger.log("Can't extract #{entry}: #{e.message}", true)
  			end
  		end
  		$logger.footer("[#{extracted}/#{entries.size}] projects are been uncompressed", true)
	end

end