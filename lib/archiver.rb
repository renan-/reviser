require 'fileutils'
require_relative 'extractor'
require_relative 'component'

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
	end

	#
	# Method which extract an archive
	# which contains all computing projects.
	# This method extract in first time the archive
	# and after all extracted files.
	#
	def run
		# Extract the original archive
		Archiver.extract(@src, @destination)
		
		# Extract all sub archives
		entries = Dir.entries(@destination).reject{|entry| entry == '.' || entry == '..'}
		entries.each do |entry|
			ext = File.extname(entry)
			basename = File.basename(entry, ext)

  			Archiver.extract(File.join(@destination,File.basename(entry)), File.join(@destination,basename))
			FileUtils.rm(File.join(@destination,entry))
  		end
	end


end

Archiver.extract('lib.cpio', 'coucou')