require 'fileutils'
require_relative 'extractor'
require_relative 'component'


# Manage uncompression of archive.
# The archive contains all computing projects.
#
# Author::	Yann Prono

class Archiver < Component
	# Get archive to use and the path directory.
	def initialize
		super

		@src = @Cfg[:src]
		@destination = @Cfg[:dest]

		begin
			# Raise exception if the archive doesn't exist
			raise "L'archive '#{@src}' n'existe pas." unless File.exists? @src
			# Create directory
			FileUtils.rm_rf(@destination) if Dir.exists? @destination
			FileUtils.mkdir @destination, :mode => 0700

			
			# Exception when the directory already exists
			rescue Errno::EEXIST
				puts "Le dossier '#{@destination}' existe deja."
			
			# Exception when the archive doesn't exist
			rescue Exception => e
				puts e.message
	 	end
	end
	

	# Extract the file into the destination directory
	# The default file used is the archive used in constructor as well the path destination.
	def extract(file = @src, destination = @destination)
		ext = File.extname(file)
		ext = ext.delete '.'
		# Check if file can be uncompressed
		if(Extractor.respond_to?(ext))
			#Call method which have the name of extension
			Extractor.send(ext,file, destination)
		else
			puts "Format '#{ext}' non supporte"
		end
	
	end

	def run
		# Extract the original archive
		extract
		
		# Extract all sub archives
		entries = Dir.entries(@destination).reject{|entry| entry == "." || entry == ".."}
		entries.each do |entry|
			ext = File.extname(entry)
			basename = File.basename(entry, ext)
			puts "Extraction de #{File.join(@destination,File.basename(entry))} vers #{File.join(@destination,basename)}"
  			extract(File.join(@destination,File.basename(entry)), File.join(@destination,basename))
			FileUtils.rm(File.join(@destination,entry))
  		end
	end