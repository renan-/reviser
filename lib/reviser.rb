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

require_relative 'component'
require_relative 'config'

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
			@@loaded_components[data[:component]] = {inputFrom: data[:inputFrom], data: nil}
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
				puts "Reviser is now running #{Reviser.titleize comp}..."

				require_relative "components/#{comp}"
				c = eval("Components::#{Reviser.titleize comp}").new ((conf[:inputFrom] != nil) && @@loaded_components[conf[:inputFrom]][:data]) || nil

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