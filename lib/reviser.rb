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
require_relative 'config'

class Reviser
	@@setup = false
	@@loadedComponents = {}

	#
	# Adds an entry with the specified data.
	# At this time, we assume the user has given us
	# a Cfg that makes sense.
	# TODO : check data
	#
	def self.load(data)
		@@loadedComponents[data[:component]] = {inputFrom: data[:inputFrom], data: nil}
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

		@@loadedComponents.each do |comp, conf|
			puts "Reviser is now running #{Reviser.titleize comp}..."

			require_relative "#{comp}"
			c = eval("#{Reviser.titleize comp}").new ((conf[:inputFrom] != nil) && @@loadedComponents[conf[:inputFrom]][:data]) || nil

			@@loadedComponents[comp][:data] = c.work
			
			puts "Done"
		end
	end

	#
	# Quite handy
	#
	def self.titleize(str)
		str.split(/ |\_/).map(&:capitalize).join("")
	end
end