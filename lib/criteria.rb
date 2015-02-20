
# Manages criterias.
# Convention over configuration
# A criteria is stored in a module.
# The filename's module contains 'tool' word.
# @author Yann Prono
class Criteria

	# All criterias available.
	@@criterias = {}

	# Load all of modules available for the analysis
	def self.load		
		modules =  Dir[File.join(File.dirname(__FILE__),'*tool*')]
				
		modules.each do |m|
			require_relative m
			name_module = camelize m
			methods = Module.const_get(name_module).instance_methods
			methods.each { |method| populate(method.to_sym, name_module) }
 		end
 	end

	# Gets the name of module 
	# @param file_module Name of the file module.
	def self.camelize(file_module) 
		File.basename(file_module).delete('.rb').split('_').each {|s| s.capitalize! }.join('')
	end

	# Gets all criterias which can be used.
	# @return [Array] all criterias
	def self.all
		@@criterias.keys.map &:to_sym
	end

	# Prepare all criterias provided by the user in the config file.
	# @param [Array] config Contains all criterias the user wants
	def self.prepare(config)
		# Get all criterias to delete
		toDelete = config.empty? ? {} : all - (config.map &:to_sym)

		# Delete now !
		toDelete.each {|criteria| @@criterias.delete(criteria.to_sym)}
	end


private 

	#  from Cfg file to symbols
	# @param criteria The criteria
	# @param module_name The name of the module.
	def self.populate(criteria, module_name) 
		@@criterias[criteria.to_sym] = module_name
	end

end