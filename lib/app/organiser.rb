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
			if(name != nil)
				name = File.join(@directory, name)
  				FileUtils.mv(entry, name)
  				$logger.log("rename #{File.basename(entry)} to #{File.basename(name)}") if options[:verbose]
  			else 
  				$logger.log("can't rename #{File.basename(entry)} (no matches with regex of Cfg.yml)", true) if options[:verbose]
  			end
  		end
	end

	# Method which moves project's directories in order to
	# have the same hierarchy for all.
	def structure
		# get all entries of projects folder
		all(@directory).each do |entry|
			chdir File.join(@directory, entry)
			$logger.log "#{entry} => #{path}" if options[:verbose]
			level = 0

			$logger.log("Files in #{path}\n#{all}") if options[:verbose]
			$logger.log("Dirs in #{path}\n#{directories}") if options[:verbose]
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
				$logger.log("Level += 1\nPath = #{path}") if options[:verbose]
				chdir File.join(path, directories.first)
				$logger.log("New path = #{path}") if options[:verbose]
			end

			# If the core of project is not at the root of directory ...
			if(level >= 1)
				Dir.glob(File.join(path,'*')).each do |file|
					FileUtils.mv(file,File.join(@directory, entry))
				end
				$logger.log("Structure #{File.join(@path)}") if options[:verbose]
				$logger.log("Removing #{File.join(@directory, entry, rm)}") if options[:verbose]
				FileUtils.rm_rf(File.join(@directory, entry, rm))
			end

		end
	end


	# Method which run the organiser
	def run
		$logger.subtitle "Rename directories" if options[:verbose]
		renameDirectories

		$logger.subtitle "Structure projects" if options[:verbose]
		structure 
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