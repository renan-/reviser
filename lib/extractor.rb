# Abstract archive Extractor.
class Extractor

	# Initialize the extractor
	# A Extractor is defined by its type (ZIP, TAR, RAR ...)
	def initialize(archive,path_dir, type)
		@src = archive
		@destination = path_dir
		@type = type
	end

	# Abstract method extract
	# Extract the archive into the directory.
	# TO-REVISE
	def extract
	end

end