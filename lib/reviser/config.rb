#
#   Reviser => a semi-automatic tool for students projects evaluation
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
require 'yaml'

module Reviser
	#
	# Externalises the configuration
	# Cfg acts like a hash whose entries are config keys
	# associated with their values
	#
	# @author Renan Strauss
	#
	class Cfg
		# Path for specialized config files for projects
		ROOT = File.join(File.dirname(File.dirname(File.dirname(__FILE__))))

		#
		# TODO : let the user dynamically add 
		# 			 his own directories
		#

		# Resources dir
		RES_DIR = 'res'
		# Project's type dir
		TYPE_DIR = 'type'

		# The available out formats
		OUT_FORMATS = [:csv, :html, :xls]

		# Is the config is loaded ?
		@@loaded = false

		def self.[](key)
	    @@mem[key] if @@loaded
		end

		def self.[]=(key, value)
			@@mem[key] = value if @@loaded
		end

		# @return true if there is the key in the config
		def self.has_key?(key)
			@@mem.has_key? key

		end

		#
		# @return The specified 
		def self.workspace_file f
			path = File.join @@workspace_root, f
			raise Errno::ENOENT, "#{path}".magenta unless File.exists?(path)

			File.new(path)
		end

		#
		# @return The specified resource path
		# TODO : put resources in dedicated folders
		# for each component or extension, so that
		# the user can omit <lang>/<ext_name>/ when
		# calling this method
		#
		def self.resource path
			self.workspace_file File.join(RES_DIR, path)
		end


		def self.load(cfg_file)
			@@mem = {}
			@@workspace_root = File.expand_path(File.dirname(cfg_file))

			#
			# read our main config file
			#
			populate YAML.load(File.read(cfg_file))

			#
			# look for project's type
			type_file = File.join(@@workspace_root, TYPE_DIR, "#{@@mem[:type]}.yml")
			begin
				type_cfg  = YAML.load(File.read(type_file))
			rescue => e
				puts "File #{type_file} not found. Aborting..."
				exit
			end

			populate YAML.load(File.read(File.join(ROOT, 'lang', "#{type_cfg['language']}.yml")))
			# So that project's type Cfg overrides
			# lang Cfg
			populate type_cfg

			setup_defaults

			@@loaded = true
		end

		def self.setup_defaults
			#
			# Default values for optional keys
			#
			@@mem[:options] ||= { verbose: true, log_dir:'logs', log_mode: 'org' }
			@@mem[:timeout] ||= 4
			@@mem[:out] ||= 'results'
			@@mem[:out_format] ||= ['csv', 'html']
			@@mem[:required_files] ||= []

			@@mem[:program_prefix] ||= ''
			@@mem[:execution_command] ||= ''
			@@mem[:execution_count] ||= 1

			@@mem[:create_git_repo] ||= false
		end

	private
		#
		# Handy method to convert string keys
		# read from Cfg file to symbols
		#
		def self.populate(hash)
			hash.each { |k, v| @@mem[k.to_sym] = v}
		end
	end
end