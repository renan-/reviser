require 'fileutils'
require 'rubygems'
require 'zip'
require_relative 'zipextractor'


# Manage uncompression of archive.
# The archive contains all computing projects
#
# Author::	Yann Prono

class Archiver
	
	# Get archive to use and the path directory.
	def initialize(archive,path_dir)
		@src = archive
		@destination = path_dir

		begin
			# Raise exception if the archive doesn't exist
			raise "L'archive '#{@src}' n'existe pas." unless File.exists? @src
			# Create directory
			FileUtils.mkdir @destination, :mode => 0700
			
			# Exception when the directory already exists
			rescue Errno::EEXIST => e
				puts "Le dossier '#{@destination}' existe deja."
			
			# Exception when the archive doesn't exist
			rescue Exception => e
				puts e.message
	 	end
	end

	# Extract the archive into the destination directory
	def extract
		ext = File.extname(@src)
		basename = File.basename(@src, ext)
		### TODO 
		### suivant l'extension, utiliser librairie appropriée ..		
	
		case ext.delete '.'
		when 'zip'
			extractor = ZipExtractor.new(@src, @destination).extract

		end
	
	end

end

# test.zip contains ONLY zip archives"
a = Archiver.new("test.zip","projects")
a.extract
