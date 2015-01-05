#
# Author:: Renan Strauss
#
require 'yaml'

class Component
	#
	# Populates with the specified
	# config file.
	#
	def self.setup(config_file)
		@@loadedComponents = []
		@@configFile = config_file
	end

	def self.load(component)
		@@loadedComponents << component
	end

	def self.run
		#files = Dir[File.dirname(__FILE__) + '*.rb'] 
		@@loadedComponents.each do |comp|
			puts "Running component #{Component.titleize comp}"

			require_relative "#{comp}"
			eval "c = #{Component.titleize comp}.new; c.run"
		end
	end

	def initialize
		@Cfg = {}

		generateProperties(YAML.load(File.read(@@configFile)))
		generateProperties(YAML.load(File.read("lang/#{@Cfg[:language]}.yml")))
	end

	def generateProperties(hash)
		attrs = Array.new
		hash.each do |k, v|
			if v.respond_to?("each") then
				cmd = "@Cfg[:#{k}] = #{v}"
			else
				cmd = "@Cfg[:#{k}] = \"#{v}\""
			end

			eval cmd
		end
	end


	def self.titleize(str)
	  str.split(/ |\_/).map(&:capitalize).join("")
	end
end