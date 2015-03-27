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
				puts "Reviser is now running "+"#{Reviser.titleize comp}".green + "..."

				require_relative "reviser/components/#{comp}" unless conf[:local]

				namespace = conf[:local] && '' || 'Components::'
				param = ((conf[:input_from] != nil) && @@loaded_components[conf[:input_from]][:data]) || nil
				
				c = eval("#{namespace}#{Reviser.titleize comp}").new param

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