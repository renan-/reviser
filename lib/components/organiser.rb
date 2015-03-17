require 'fileutils'

require_relative '../helpers/git'
require_relative '../project_properties'

# Class which organizes all directories to simplify projects'  analysis.
# Organiser renames projects folders and organises the whole of projects
# in order to have a structured folder (files at the root of folder).
#
# @author Yann Prono
# @author Renan Strauss
#
module Components
	class Organiser < Component
		include Helpers::Git
		include ProjectProperties

		# All entries to ignore during sort and organization
		$rejected_entries = ['.', '..', '__MACOSX']

		# initialize tool
		def initialize(data)
			super data

			@directory = Cfg[:dest]
			@path = @directory
			@git = nil
			@count = {}
			@students = []
			@binoms = []
			@groups = []
			@unknown = []
		end

		# Rename directories more clearly
		def rename(entry)
			name = format entry
			if name != nil
				if name != entry
					FileUtils.mv(File.join(@directory, entry), File.join(@directory,name))
					@logger.h2 Logger::INFO, "renaming #{File.basename(entry)} to #{File.basename(name)}"
				else
					@logger.h2 Logger::INFO, "#{entry} has not been renamed}, already formatted"
				end
			else
				@logger.h2 Logger::ERROR, "Can't rename #{File.basename(entry)} - Datas not found in name"
			end
		end

		# Method which moves project's directories in order to
		# have the same hierarchy for all.
		def structure(entry)
			chdir entry
			@logger.h2 Logger::INFO, "#{entry} => #{@path}"
			level = 0
			@logger.h2 Logger::INFO, "Files in #{@path}"
			@logger.h3 Logger::INFO, "#{all}"

			@logger.h2 Logger::INFO, "Dirs in #{@path}"
			@logger.h3 Logger::INFO, "#{directories}"
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
				@logger.h2 Logger::DEBUG, "Level += 1\nPath = #{@path}"
				chdir directories.first
				@logger.h2 Logger::DEBUG, "New path = #{@path}"
			end

			# If the core of project is not at the root of directory ...
			if level >= 1
				Dir.glob(File.join(@path,'*')).each do |file|
					FileUtils.mv(file,File.join(@directory, entry))
				end
				@logger.h2 Logger::INFO, "Structuring #{File.join(@path)}"
				@logger.h2 Logger::INFO, "Removing #{File.join(@directory, entry, rm)}"
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
			projects = Dir.entries(@directory) - $rejected_entries
			projects.each do |entry|
				@logger.h1 Logger::INFO, "Work on #{entry}"
				@logger.h1 Logger::INFO, "Structure project"
				structure entry

				@logger.h1 Logger::INFO, "Initializing git repo"
				git entry

				@logger.h1 Logger::INFO, "Renaming directory"
				rename entry
				@logger.newline
			end

			@logger.h1 Logger::INFO, "#{@groups.size} groups have been detected"
			@logger.h1 Logger::INFO, "#{@students.size} students have been detected"

			unless @unknown.empty?
				@logger.newline
				@logger.h1 Logger::ERROR, "#{@unknown.size} projects didn't matched with regex\n"
				@unknown.each {|pro| @logger.h2 Logger::ERROR, "#{pro}" }
			end
			unless @students.empty?
				@logger.newline
				@logger.h1 Logger::INFO, "students:"
				@students.each {|student| @logger.h2 Logger::INFO, "#{student}" }
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
end