require 'fileutils'
require_relative 'extractor'
require_relative 'component'
require_relative 'generator_log'

#
# Manage uncompression of archive.
# The archive contains all computing projects.
#
# @example The simple way to extract a compressed file is : 
# 		Archiver.extract(myFile, myDirectory)
#
# @Author	Yann Prono
#
class Archiver < Component

	attr_reader :src, :destination

	# Logger of the archiver
	$logger

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
		FileUtils.rm_rf(destination)
		FileUtils.mkdir destination, :mode => 0700
	end
	
	#
	# Extract the file into the destination directory.
	# @param file_name [String] the name of the archive.
	# @param destination [String] the destination directory.
	#
	def self.extract(file_name, destination)
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
		$logger.title ("#{Archiver.name}")

		$logger.subtitle ("First extraction ")
		# Extract the original archive
		Archiver.extract(@src, @destination)
		$logger.subtitle ("Extraction of sub archives")
		
		# Extract all sub archives
		entries = Dir.entries(@destination).reject{|entry| entry == '.' || entry == '..'}
		extracted = 0
		entries.each do |entry|
			ext = File.extname(entry)
			basename = File.basename(entry, ext)

  			Archiver.extract(File.join(@destination,File.basename(entry)), File.join(@destination,basename))

			FileUtils.rm_rf(File.join(@destination,entry))
			extracted += 1
  		end
  		$logger.footer("#{extracted} projects are been uncompressed", true)
	end


end