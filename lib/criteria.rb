
# Manages criterias.
#
# @author Yann Prono
class Criteria

	# All criterias available.
	@@criterias = {}

	# Load all of modules available for the analysis
	def self.load
		modules =  Dir['*tool*']
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

private 

	#  from Cfg file to symbols
	# @param criteria The criteria
	# @param module_name The name of the module.
	def self.populate(criteria, module_name) 
		@@criterias[criteria.to_sym] = module_name
	end

end

Criteria.load