
# Represents a criterias
# @author Yann Prono
class Criteria

	@@loaded = {}
	# Load all of modules available for the analysis
	def self.load
		modules =  Dir['*tool*']
		modules.each do |m|
			require_relative m
			name_module = camelize m
			methods = Module.const_get(name_module).instance_methods
			Criteria.populate(name_module, methods)
 		end

 		puts @@loaded.inspect
 	end

	# Get name of module
	def self.camelize(file_module) 
		File.basename(file_module).delete('.rb').split('_').each {|s| s.capitalize! }.join('')
	end

	def self.populate(k,v) 
		@@loaded[k.to_sym] = v
	end

end


Criteria.load