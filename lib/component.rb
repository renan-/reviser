#
# Author:: Renan Strauss
#
require 'yaml'

class Component
	# Each component has a logger (currently a txt file)
	$logger

	#
	# Don't forget to call super in your component's initializer !
	# This method is all about : it stores the data from another
	# component accordingly to what you told to Reviser, and
	# creates a hash for child to easily access config file values
	#
	def initialize(data)
		@data = data
	end

protected
	#
	# @return all options for all components if they exist in config file.
	def options
		(:options =~ Cfg) ? Cfg[:options] : { :verbose => false }
	end
end