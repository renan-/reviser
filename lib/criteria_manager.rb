require_relative 'config'
# Manage criteria.
# Criteria provides all criteria available 
# that can be used for the analysis.
#
# Convention over configuration !
#
# Currently (I said 'currently' Renan), criteria is stored in a module.
# The filename's module contains 'tool' word.
#
# @author Yann Prono
#
class CriteriaManager

	# All criterias available.
	# :criterion => Name of the module
	@criteria

	def initialize
		@criteria = Hash.new
		load
	end

	# Load all of modules available for the analysis
	def load		
		modules =  Dir[File.join(File.dirname(__FILE__),'*tool*')]
		
		modules.each do |m|
			require_relative m
			module_name = camelize m
			methods = Module.const_get(module_name).instance_methods
			methods.each { |method| populate(method, module_name) }
 		end	
 	end

	# Gets the name of module 
	# @param file_module Name of the file module.
	def camelize(file_module) 
		File.basename(file_module).delete('.rb').split('_').each {|s| s.capitalize! }.join('')
	end

	# Gets all criterias which can be used.
	# @return [Array] all criterias
	def all
		@criteria.keys.map &:to_sym
	end

	# Prepare all criterias provided by the user in the config file.
	# @param [Array] criteria Contains all criterias the user wants
	def prepare(crit_config)
		# Get all criterias to delete
		to_delete = crit_config.empty? ? {} : all - (crit_config.map &:to_sym)
		# Delete now !
		to_delete.each {|crit| @criteria.delete(crit.to_sym)}
	end


	private 

	#  from Cfg file to symbols
	# @param criterion The criteria
	# @param module_name The name of the module.
	def populate(criterion, module_name)
		@criteria[criterion.to_sym] = module_name
	end

end