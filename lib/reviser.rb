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
require 'mkmf'
require 'colorize'
require 'rubygems'

require_relative 'reviser/component'
require_relative 'reviser/config'

require_relative 'reviser/helpers/project'
require_relative 'reviser/helpers/system'

class String
	#
	# We need the 'underscore' method from Rails API to
	# convert CamelCaseNames to underscore_names
	#
	def underscore
		self.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
		gsub(/([a-z\d])([A-Z])/,'\1_\2').
		tr("-", "_").
		downcase
	end
end

#
# Very handy (that's why it's in global scope)
# Raises an exception unless the given gem is installed
# Requires the gem if it is installed
#
def require_gem gem_name
	unless Gem::Specification::find_all_by_name(gem_name).any?
		raise Gem::LoadError, "#{gem_name}".yellow + " => ".white + "gem install #{gem_name}".magenta
	end

	require gem_name
end

module Reviser
	#
	# @author Renan Strauss
	#
	# This class is basically here to give the user
	# a generic and comprehensive way to use and
	# customize the behavior of our tool.
	# The main idea is that the user should not
	# instantiate components himself, nor worry
	# about the data these components exchange.
	# It is the API entry point.
	#
	class Reviser
		@@setup = false

		@@loaded_components = {}
		@@registered_extensions = []

		def self.registered_extensions
			@@registered_extensions
		end

		#
		# Adds an entry with the specified data.
		#
		def self.load(data)
			raise ArgumentError unless data.has_key?(:component)

			data[:input_from] ||= nil
			data[:local] ||= false

			@@loaded_components.store data[:component],
			{
				:input_from => data[:input_from],
				:local => data[:local],
				:data => nil
			}
		end
		
		#
		# Registers the specified extension
		# (its methods will be available for analysis)
		#
		def self.register(data)
			raise ArgumentError unless data.has_key?(:extension)

			@@registered_extensions << data[:extension]
		end

		#
		# Loads the configuration from given config_file
		#
		def self.setup(config_file)
			Cfg.load config_file
			@@setup = true
		end

		#
		# Basically runs each loaded component.
		# The exection order is based on the loading order.
		#
		def self.run
			raise RuntimeError unless @@setup

			if Cfg.has_key?(:options) && Cfg[:options].has_key?(:log_dir)
				FileUtils.mkdir Cfg[:options][:log_dir] unless Dir.exist? Cfg[:options][:log_dir]
			end

			#
			# Need to change this ASAP in order to
			# let users load their own components
			#
			@@loaded_components.each do |comp, conf|
				puts "[ " + "Running ".yellow + "#{Reviser.titleize comp}".blue + " ]"

				require_relative "reviser/components/#{comp}" unless conf[:local]

				namespace = conf[:local] && '' || 'Components::'
				param = ((conf[:input_from] != nil) && @@loaded_components[conf[:input_from]][:data]) || nil
				
				c = eval("#{namespace}#{Reviser.titleize comp}").new param

				begin
					@@loaded_components[comp][:data] = c.work
				rescue Interrupt => i
					puts 'Bye bye'
				rescue Gem::LoadError => e
					puts 'Missing gem'.light_red + "\t" + e.message
					exit
				rescue Exception => ex
					puts 'Error'.red + "\t" + ex.message
					exit
				end
				
				puts "[ " + "Done".green + " ]"
			end

			# To handle multiple loads
			# and calls to run
			@@loaded_components = {}
		end

		#
		# Quite handy
		#
		def self.titleize(str)
			str.split(/ |\_/).map(&:capitalize).join('')
		end
	end
end