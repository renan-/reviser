#
# The abstract class Component
# Even though Ruby doesn't have abstract classes,
# we force inheriting classes to implement the run
# method that will be called during reviser's execution
#
# @author Renan Strauss
#
require_relative 'loggers/logger'

module Reviser
	class Component
		#
		# Don't forget to call super in your component's initializer !
		# This method is all about : it stores the data from another
		# component accordingly to what you told to Reviser, and
		# creates a hash for child to easily access config file values
		#
		def initialize(data = nil)
			@data = data
			
			ext = options[:log_mode]
			log_file = File.join(options[:log_dir], "#{self.class.name.split('::').last}.#{ext}")

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

		#
		# Be kind to our childs and let them access
		# ressources files easily
		#
		# @return The specified resource path
		# TODO : put resources in dedicated folders
		# for each component or extension, so that
		# the user can omit <lang>/<ext_name>/ when
		# calling this method
		#
		def resource path
			Cfg::resource path
		end

	protected
		#
		# @return all options for all components if they exist in config file.
		#
		def options
			Cfg[:options]
		end
	end
end