#
# Author:: Renan Strauss
#
# This class is basically here to give the user
# a generic and comprehensive way to use and
# customize the behavior of our tool.
# The main idea is that the user should not
# instantiate components himself, nor worry
# about the data these components exchange.
#
require 'mkmf'
require 'colorize'

require_relative 'reviser/component'
require_relative 'reviser/config'

require_relative 'reviser/helpers/git'
require_relative 'reviser/helpers/project'
require_relative 'reviser/helpers/system'

module Reviser
	class Reviser
		@@setup = false
		@@loaded_components = {}

		#
		# Adds an entry with the specified data.
		# At this time, we assume the user has given us
		# a Cfg that makes sense.
		# TODO : check data
		#
		def self.load(data)
			data[:local] ||= false

			@@loaded_components.store data[:component],
			{
				:inputFrom => data[:inputFrom],
				:local => data[:local],
				:data => nil
			}
		end

		def self.setup(config_file)
			@@setup = true
			Cfg.load config_file
		end

		#
		# Basically runs each loaded component.
		# The exection order is based on the loading order.
		#
		def self.run
			raise ArgumentError unless @@setup

			if Cfg.has_key?(:options) && Cfg[:options].has_key?(:log_dir)
				FileUtils.mkdir Cfg[:options][:log_dir] unless Dir.exist? Cfg[:options][:log_dir]
			end

			#
			# Need to change this ASAP in order to
			# let users load their own components
			#
			@@loaded_components.each do |comp, conf|
				puts "Reviser is now running "+"#{Reviser.titleize comp}".green + "..."

				require_relative "reviser/components/#{comp}" unless conf[:local]

				namespace = conf[:local] && '' || 'Components'
				param = ((conf[:inputFrom] != nil) && @@loaded_components[conf[:inputFrom]][:data]) || nil
				
				c = eval("#{namespace}::#{Reviser.titleize comp}").new param

				@@loaded_components[comp][:data] = c.work
				
				puts 'Done'
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