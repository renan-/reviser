#
# Author:: Renan Strauss
#
require 'yaml'

class Component
	#
	# Sets the config file to read from
	# when initializing a component
	#
	def self.setup(config_file)
		@@configFile = config_file
	end

	#
	# Don't forget to call super in your component's initializer !
	# This method is all about : it stores the data from another
	# component accordingly to what you told to Reviser, and
	# creates a hash for child to easily access config file values
	#
	def initialize(data)
		@data = data
		@cfg = {}

		populate YAML.load(File.read(@@configFile))
		sort_cfg = YAML.load(File.read(File.join(File.dirname(File.dirname(__FILE__)),
			'sort',"#{@cfg[:sort]}.yml")))

		populate YAML.load(File.read(File.join(File.dirname(File.dirname(__FILE__)),
			'lang',"#{sort_cfg['language']}.yml")))
		# So that project's type config overrides
		# lang config
		populate sort_cfg
	end

	#
	# Handy method to convert string keys
	# read from config file to symbols
	#
	def populate(hash)
		hash.each { |k, v| @cfg[k.to_sym] = v}
	end
end