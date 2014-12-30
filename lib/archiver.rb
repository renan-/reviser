require 'fileutils'
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

	# Extract the file into the destination directory
	# The default file used is the archive used in constructor as well the path destination.
	def extract(file = @src, destination = @destination)
		ext = File.extname(file)
		basename = File.basename(file, ext)
		### TODO 
		### suivant l'extension, utiliser librairie appropriée ..		
	
		case ext.delete '.'
		when 'zip'
			extractor = ZipExtractor.new(file, destination).extract
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
  			extract(File.join(@destination,File.basename(entry)), File.join(@destination,basename))
  		end
	
	end

end

# test.zip contains ONLY zip archives"
a = Archiver.new("test.zip","projects")
a.run
