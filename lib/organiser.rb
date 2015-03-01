require 'fileutils'

require_relative 'git'

# Class which organizes all directories to simplify projects'  analysis.
# Organiser renames projects folders and organises the whole of projects
# in order to have a structured folder (files at the root of folder).
#
# @author Yann Prono
# @author Renan Strauss
#
class Organiser < Component
	include Git

	# All entries to ignore during sort and organization
	$rejected_entries = ['.', '..', '__MACOSX']

	# initialize tool
	def initialize(data)
		super data

		@directory = Cfg[:dest]
		@path = @directory
		@git = nil
	end

	# Rename directories more clearly
	def rename(entry)
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

	# Method which moves project's directories in order to
	# have the same hierarchy for all.
	def structure(entry)
		chdir entry
		@logger.info { "#{entry} => #{@path}" }
		level = 0

		@logger.info { "Files in #{@path}\n#{all}" }
		@logger.info {"Dirs in #{@path}\n#{directories}" }
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
			@logger.debug { "Level += 1\nPath = #{@path}" }
			chdir directories.first
			@logger.debug { "New path = #{@path}" }
		end

		# If the core of project is not at the root of directory ...
		if level >= 1
			Dir.glob(File.join(@path,'*')).each do |file|
				FileUtils.mv(file,File.join(@directory, entry))
			end
			@logger.info { "Structuring #{File.join(@path)}" }
			@logger.info {"Removing #{File.join(@directory, entry, rm)}" }
			FileUtils.rm_rf(File.join(@directory, entry, rm))
		end

		@path = @directory
	end

	def git(entry)
		Dir.chdir File.join(@directory, entry) do
			git_init
			git_add
			git_commit
		end
	end


	# Method which run the organiser
	def run
		directories.each do |entry|
			@logger.info { 'Structure projects' }
			structure entry

			@logger.info { 'Initializing git repo' }
			git entry

			@logger.info { 'Renaming directories' }
			rename entry
		end
	end

private

	#
	# Take attention : these accessors
	# are meant to be used by structure
	# only ! Because @path is initialized
	# for that, and used only in this def
	#
	def all
		Dir.entries(@path) - $rejected_entries
	end

	def directories
		all.select { |e| File.directory? File.join(@path, e) }
	end

	def chdir(dir)
		base = @path
		@path = File.join(base, dir)
	end
end