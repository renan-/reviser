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
		@@configFile = config_file
	end

	def run
		
	end

	def initialize(data)
		@data = data
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
end