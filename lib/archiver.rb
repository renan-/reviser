require 'fileutils'
require_relative 'extractor'
require_relative 'component'

#
# Manage uncompression of archive.
# The archive contains all computing projects.
#
# The simple way to extract a compressed file is 
# to use the +extract+ class method : 
#
# 		Archiver.extract(myFile, myDirectory)
#
# Author::	Yann Prono
#
class Archiver < Component

	
	# Get archive to use and the path directory.
	def initialize(data)
		super data

		@src = @Cfg[:src]
		@destination = @Cfg[:dest] 

		# Create directory
		FileUtils.rm_rf(@destination) if Dir.exists? @destination
		FileUtils.mkdir @destination, :mode => 0700
	end
	
	# Extract the file into the destination directory.
	def self.extract(file_name, destination)
		raise Errno::ENOENT unless File.exists?(file_name)
		ext = File.extname(file_name)
		ext = ext.delete '.'

		# Check if file can be uncompressed
		if Extractor.respond_to?(ext)
			#Call method which have the name of extension
			Extractor.send(ext,file_name, destination)
		else
			puts "Format '#{ext}' non supporte"
		end

		rescue Errno::ENOENT
			puts "# File '#{file_name}'' not found. Check if the file exists."
	end

	#
	# Method which extract an archive
	# which contains all computing projects.
	# The name archive and the directory destination are included in +@data.
	# This method extract in first time the archive
	# and after all extracted files.
	#
	# The structure of the archive is : 
	# 	- archive.zip
	#		- project_1.tar.gz
	#		- project_2.zip
	# 		- project_3.rar 
	# 		- project_...
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