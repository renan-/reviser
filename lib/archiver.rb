
# Manage uncompression of archive.

class Archiver

	def initialize(archive,p_dir)
		@src = archive
		@destination = p_dir
	end

end


a = Archiver.new("src","fodler")
