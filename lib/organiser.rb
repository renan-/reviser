require 'fileutils'

# Class which organizes all directories to simplify projects' analysis.
#
# Author::	Yann Prono
class Organiser < Component

	# All entries to ignore during sort and organization
	$rejectedEntries = ['.', '..', '__MACOSX']

	# initialize tool
	def initialize(data)
		super data

		@directory = @cfg[:dest]		
	end

	# Rename directories more clearly
	def renameDirectories
		# If the regex doesn't match
		count = 0

		# get all entries of projects folder
		entries = (Dir.entries(@directory) - $rejectedEntries)
		entries.each do |entry|
			#apply regex and take first match
			name = entry.scan(@cfg[:projects_names]).first
			entry = File.join(@directory, entry)
			if(name != nil)
				name = File.join(@directory, name)
  				FileUtils.mv(entry, name)
  				$logger.log("rename #{File.basename(entry)} to #{File.basename(name)}") if options[:verbose]
  			else 
  				$logger.log("can't rename #{File.basename(entry)} (no matches with regex of config.yml)", true) if options[:verbose]
  			end
  		end
	end

	# Method which moves project's directories in order to
	# have the same hierarchy for all.
	def structure
		# get all entries of projects folder
		entries = (Dir.entries(@directory) - $rejectedEntries)
		entries.each do |entry|
			path = File.join(@directory, entry)
			level = 0
			mem = directories path

			# directory to delete if the project directory is not structured
			rm = mem.size == 1 && mem.first || ''
			# Loop to find the core of project
			#
			# Basically running through
			# each level of directories
			# while there are only directories
			# in the current directory
			#
			while mem.size == 1
				level += 1
				path = File.join(path, mem.first)

				mem = directories path
			end
			# If the core of project is not at the root of directory ...
			if(level >= 1)
				Dir.glob(File.join(path,'*')).each do |file|
					FileUtils.mv(file,File.join(@directory, entry))
				end
				$logger.log("Structure #{File.join(path)}") if options[:verbose]
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

	def directories(path)
		(Dir.entries(path) - $rejectedEntries).select { |e| File.directory? File.join(path, e) }
	end
end