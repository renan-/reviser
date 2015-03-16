#
# Author:: Renan Strauss
#
require 'yaml'
require_relative 'loggers/logger'

class Component
	
	# Each component has a logger (currently a txt file)
	# $logger

	#
	# Don't forget to call super in your component's initializer !
	# This method is all about : it stores the data from another
	# component accordingly to what you told to Reviser, and
	# creates a hash for child to easily access config file values
	#
	def initialize(data)
		@data = data
		ext = options.has_key?(:log_mode) && options[:log_mode] || 'txt'
		log_file = File.join(options.has_key?(:log_dir) && options[:log_dir] || '.', "#{self.class.name}.#{ext}")
		# For now, we output to stderr if verbose option is not set
		# In the future, it would be a good idea to always have logs,
		# but to let the user change the level
		@logger = Loggers::Logger.new(options[:verbose] && log_file || STDERR)
	end 

	# Place-holder
	# Just like an abstract method
	def run
		raise NotImplementedError, 'All components must implement a run method'
	end

	# Method template
	# So that when somebody implements a custom
	# Component, he doesn't have to carry about
	# logger being closed or not.
	# Might be even more useful at some point
	def work
		data = run
		@logger.close

		data
	end

protected
	#
	# @return all options for all components if they exist in config file.
	def options
		(Cfg.has_key? :options) && Cfg[:options] || { :verbose => false }
	end
end