require 'fileutils'

# Class which organizes all directories to simplify projects' analysis.
#
# @author Yann Prono
# @author Renan Strauss
#
class Organiser < Component

	attr_accessor :path

	# All entries to ignore during sort and organization
	$rejectedEntries = ['.', '..', '__MACOSX']

	# initialize tool
	def initialize(data = nil)
		super data

		@directory = Cfg[:dest]
		@path = ''		
	end

	# Rename directories more clearly
	def renameDirectories
		# get all entries of projects folder
		all(@directory).each do |entry|
			#apply regex and take first match
			name = entry.scan(Cfg[:projects_names]).first
			entry = File.join(@directory, entry)
			if name != nil
				name = File.join(@directory, name)
  				FileUtils.mv(entry, name)
  				@logger.info { "renaming #{File.basename(entry)} to #{File.basename(name)}" }
  			else 
  				@logger.warn { "can't rename #{File.basename(entry)} (no matches with regex of config)" }
  			end
  		end
	end

	# Method which moves project's directories in order to
	# have the same hierarchy for all.
	def structure
		# get all entries of projects folder
		all(@directory).each do |entry|
			chdir File.join(@directory, entry)
			@logger.info { "#{entry} => #{path}" }
			level = 0

			@logger.info { "Files in #{path}\n#{all}" }
			@logger.info {"Dirs in #{path}\n#{directories}" }
			# directory to delete if the project directory is not structured
			rm = directories.first
			
			# Loop to find the core of project
			#
			# Basically running through
			# each level of directories
			# while there are only directories
			# in the current directory
			#
			while all == directories
				level += 1
				@logger.debug { "Level += 1\nPath = #{path}" }
				chdir File.join(path, directories.first)
				@logger.debug { "New path = #{path}" }
			end

			# If the core of project is not at the root of directory ...
			if level >= 1
				Dir.glob(File.join(path,'*')).each do |file|
					FileUtils.mv(file,File.join(@directory, entry))
				end
				@logger.info { "Structuring #{File.join(@path)}" }
				@logger.info {"Removing #{File.join(@directory, entry, rm)}" }
				FileUtils.rm_rf(File.join(@directory, entry, rm))
			end

		end
	end


	# Method which run the organiser
	def run
		@logger.info { "Renaming directories" }
		renameDirectories

		@logger.info { "Structure projects" }
		structure

		@logger.close
	end

private

	def all(path = @path)
		Dir.entries(path) - $rejectedEntries
	end

	def directories
		all.select { |e| File.directory? File.join(@path, e) }
	end

	def chdir(dir)
		@path = dir
	end
end