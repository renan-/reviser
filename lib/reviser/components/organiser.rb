#
#   Reviser => a semi-automatic tool for student's projects evaluation
#
#   Copyright (C) 2015 Renan Strauss
#   Copyright (C) 2015 Yann Prono
#   Copyright (C) 2015 Romain Ruez
#   Copyright (C) 2015 Anthony Cerf
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
require 'fileutils'
require 'rubygems'

require_relative '../helpers/project'

module Reviser
	module Components

		# Class which organizes all directories to simplify projects' analysis.
		# Organiser renames projects folders and organises the whole of projects
		# in order to have a structured folder (files at the root of folder)
		# During this step, a git repository will be created, with an initial commit.
		#
		# The other important task of Organiser is to detect all students, all binoms and all groups, 
		# thank to the directory name.
		#
		# @author Yann Prono
		# @author Renan Strauss
		#
		class Organiser < Component
			include Helpers::Project::Naming

			# All entries to ignore during sort and organization
			$rejected_entries = ['.', '..', '__MACOSX']

			# initializes tool.
			# The initialization will prepare all to 
			# crate a git repo, save all detected students as well someone who 
			# doesn't respect convention ...
			Organiser 
			def initialize(data)
				raise ArgumentError if data == nil || !data.respond_to?('each')

				super data

				@directory = Cfg[:dest]
				@path = @directory
				@git = nil
				@students = []
				@binoms = []
				@projects_per_group = {}
				@unknown = []
				@results = []

				# How many patterns are in the pseudo-regex?
				@count_patterns = {}

				# Is git present ?
				if Cfg[:create_git_repo]
					require_gem 'git'
					require_relative '../helpers/git'

					self.class.send(:include, Helpers::Git)
				end
			end

			# Renames directories more clearly.
			# @param entry [String] path of the entry to rename.
			def rename(entry)
				name = format entry
				if name != nil
					if name != entry
						new_path = File.join(@directory, name)
						FileUtils.mkdir_p(new_path.split(File.basename(new_path))[0])
						FileUtils.mv(File.join(@directory, entry), new_path, :force => true)
						
						@logger.h2 Logger::INFO, "renaming #{File.basename(entry)} to #{File.basename(name)}"
					else
						@logger.h2 Logger::INFO, "#{entry} has not been renamed}, already formatted"
					end
				else
					@logger.h2 Logger::ERROR, "Can't rename #{File.basename(entry)} - Datas not found in name"
				end
				name
			end

			# Method which moves project's directories in order to
			# have the same hierarchy for all project.
			# @param entry [String] path of the entry to structure.
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
				# Basically running through each level of directories
				# while there is only one directory in the current directory.
				# Sometimes needed when archives have a sub-folder with their name.
				# In case the student created multiple nested folders, we don't
				# do anything.
				#
				while all == directories && directories.size == 1
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

			# Initializes a git repo.
			# @param entry [String] Directory to process.
			def git(entry)
				Dir.chdir File.join(@directory, entry) do
					git_init
					git_add
					git_commit
				end
			end


			# Method which runs the organiser.
			# It will apply all importants methods of this class for each project.
			def run
				@data.each do |entry|
					
					@logger.h1 Logger::INFO, "Work on #{entry}"
					@logger.h1 Logger::INFO, "Structure project"
					structure entry

					if Cfg[:create_git_repo]
						@logger.h1 Logger::INFO, "Initializing git repo"
						git entry
					end

					@logger.h1 Logger::INFO, "Renaming directory"
					new_path = rename entry
					@logger.newline
					@results << new_path
				end

				@logger.h1 Logger::INFO, "#{@projects_per_group.keys.size} group#{'s' if @projects_per_group.keys.size > 1} have been detected"
				@logger.h1 Logger::INFO, "#{@students.size} student#{'s' if @students.size > 1} have been detected"
				@logger.h1 Logger::INFO, "#{@binoms.size} binom#{'s' if @binoms.size > 1} have been detected"

				formalized = []
				@projects_per_group.each { |k,v| formalized << "#{k.to_s}: #{v} project#{'s' if v > 1}" }
				log_resume(formalized, Logger::INFO, "Groups:")
				log_resume(@students, Logger::INFO, "Students:")
				log_resume(@binoms, Logger::INFO, "Binoms:")

				log_resume(@unknown, Logger::ERROR, "\n#{@unknown.size} projects didn't matched with regex")
				
				@results
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


			# Shortcut for logs ...
			# @param data [Array] to loop.
			# @param severity [Integer] Severity of the log.
			# @param message [String] Message to log before writing data.
			def log_resume(data ,severity, message)
				unless data.empty?
					@logger.newline
					@logger.h1 severity, message
					data.each {|d| @logger.h2 severity, "#{d}" }
				end
			end
			
		end
	end
end