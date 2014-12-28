require 'fileutils'

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

end

a = Archiver.new("src","fodler")
