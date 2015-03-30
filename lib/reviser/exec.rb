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
require 'thor'
require 'fileutils'
require 'colorize'

require_relative '../reviser'
require_relative 'helpers/criteria'

module Reviser
	#
	# Class used for managing all actions in command line
	# This class enables the user to interact with the programm in command line.
	# It use the powerful toolkit Thor for building command line interfaces
	#
	# @author Yann Prono
	#
	class Exec < Thor

		VERSION = '0.0.3.1'

		map '--version' => :version
		map '-v' => :version

		@@setup = false

		def initialize(*args)
			super
			# If config.yml already exists in the working
			# directory, then we setup reviser here
			config_file = File.expand_path('config.yml')
			setup config_file if File.exist? config_file
		end

		# Create a environnment for checking projects
		# This method only copies the config file into the current directory.
		desc 'init DIRECTORY', 'Initialize Reviser workspace. DIRECTORY ||= \'.\''
		def init(dir = '.')
			# Import all files and directories
			init_workspace dir
			
			setup File.expand_path(File.join(dir, 'config.yml')) unless @@setup

			puts "Customize config.yml to your needs @see docs".yellow
			puts 'Then simply execute \'reviser work\' to launch analysis.'.yellow
		end


		# Clean the directory of logs, projects and results.
		desc 'clean', 'Remove generated files (logs, projects, results files ...)'
		def clean
			if File.exist? 'config.yml'
				FileUtils.rm_rf(Cfg[:dest], :verbose => true)
				if Cfg.has_key?(:options) && Cfg[:options].has_key?(:log_dir)
					FileUtils.rm_rf(Cfg[:options][:log_dir], :verbose => true)
				else
					FileUtils.rm_f(Dir['*.txt'], :verbose => true)
				end

				if Cfg[:out_format].respond_to? 'each'
					Cfg[:out_format].each { |format| FileUtils.rm_f(Dir["*.#{format}"], :verbose => true) }
				else
					FileUtils.rm_f(Dir["*.#{Cfg[:out_format]}"], :verbose => true)
				end

				# We shall not delete it because the user is likely to
				# add his own files and doesn't want to lose them every
				# single time
				#FileUtils.rm_rf(Cfg[:res_dir], :verbose => true)
			else
				message("Error".red, "'config.yml' doesn't exist! Check if you are in the good directory.")
			end

		end


		# Let do it for analysis.
		# @param current_dir [String] the directory where the programm has to be launched.
		desc 'work', 'Run components to analyse computing projects'
		def work
			if File.exists? 'config.yml'
				begin
					Reviser::load :component => 'archiver'
					Reviser::load :component => 'organiser', :input_from => 'archiver'
					Reviser::load :component => 'checker', :input_from => 'organiser'
					Reviser::load :component => 'generator', :input_from => 'checker'

					Reviser::run
				rescue Interrupt => i
					puts 'Bye bye'
				rescue Gem::LoadError => e
					message('Missing gem'.light_red, e.message)
				rescue Exception => e
					message('Error'.red, e.message)
				end
			else
				message('Error'.red, "'config.yml' file doesn't exist! @see 'reviser init'")
			end
		end

		desc 'extract', 'Extract and organise all computing projects'
		def extract
			begin
				Reviser::load :component => 'archiver'
				Reviser::load :component => 'organiser', :input_from => 'archiver'
				
				Reviser::run
			rescue Interrupt => i
				puts 'Bye bye'
			rescue Gem::LoadError => e
				message('Missing gem'.yellow, e.message)
			rescue Exception => e
				message('Error'.red, e.message)
			end
		end

		#
		# For the moment, associate a label to a criterion (method).
		#
		# Cette methode me fait penser qu'on devrait vraiment configurer
		# le dossier de base ici, et le passer dans la config parce que,
		# par defaut, les modifs sur le fichier labels.yml seront faites
		# sur le fichier labels.yml dans le dossier ou est le programme,
		# et non dans le dossier ou travaille l'utilisateur
		#
		desc 'add METH \'LABEL\'', 'Associates LABEL with METH analysis def'
		def add meth, label
			res = Helpers::Criteria::Labels.add meth, label
			message "#{res} label".green,meth + " => " + label
		end

		desc 'version', 'Print out version information'
		def version
			puts "Reviser".yellow + " " + "#{VERSION}".light_red + " Copyright (C) 2015  Renan Strauss, Yann Prono, Anthony Cerf, Romain Ruez"
		end


		no_tasks do
	  		# A Formatter message for command line
	  		def message(keyword, desc)
	  			puts "\t#{keyword}\t\t#{desc}"
			end

			def setup(config_file)
				Reviser::setup config_file

				@@setup = true
			end

			# Initialize workspace copying all files et directories.
			# @param dir Directory to init.
			def init_workspace dir
				FileUtils.mkdir dir unless File.directory? dir

				# First copy directories
				[Cfg::RES_DIR, Cfg::TYPE_DIR].each do |d|
					path = File.join(Cfg::ROOT, d)
					if File.directory? path
						unless File.directory? File.join(dir, d)
							FileUtils.cp_r path, dir
							message('Create', dir == '.' && d || File.join(dir, d))
						end
					end
				end

				# Then the config file
				['config.yml', 'labels.yml'].each do |tpl|
					FileUtils.cp File.join(Cfg::ROOT, tpl), dir
					message('Create', dir == '.' && tpl || File.join(dir, tpl))
				end
			end

		end

	end
end
Reviser::Exec.start(ARGV)
