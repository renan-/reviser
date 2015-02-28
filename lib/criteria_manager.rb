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

	# :criterion => label of criterion
	@name_crits

	PWD = File.dirname(__FILE__)

	# Path of extensions
	EXT = File.join(File.dirname(PWD), 'ext')

	def initialize
		@criteria = Hash.new
		@name_crits = Hash.new
		load(PWD, '*tool*')
		load(EXT, '*')
		
		load_labels :criterias
		load_labels :extensions

		prepare :criterias
		prepare :extensions
	end


	# Gets all criterias which can be used.
	# @return [Array] all criterias
	def all
		@criteria.keys.map &:to_sym
	end


	# Prepare all criterias provided by the user in the config file.
	# @param key key of config file
	def prepare(key)
		if Cfg.has_key? key
			# Get all criterias to delete
			to_delete = Cfg[key].empty? ? {} : all - (Cfg[key].keys.map &:to_sym)

			# Delete now !
			to_delete.each {|crit| @criteria.delete(crit.to_sym)}
		end
	end


	private 

	#  from Cfg file to symbols
	# @param criterion The criteria
	# @param module_name The name of the module.
	def populate(criterion, module_name)
		@criteria[criterion.to_sym] = module_name
	end

	# Load all of modules available for the analysis
	# @param directory Directory where search of modules is done.
	# @param regex regex to find name of modules.
	def load(directory, regex = '*')
		modules =  Dir[File.join(directory, regex)]

		modules.each do |m|
			require_relative m
			ext = File.extname m
			module_name = camelize(File.basename(m,ext))
			methods = Object.const_get(module_name).instance_methods
			methods.each { |method| populate(method, module_name) }
 		end	
 	end

	# Gets the name of module 
	# @param file_module Name of the file module.
	def camelize(file_module) 
		file_module.split('_').each {|s| s.capitalize! }.join('')
	end

	# Load labels given by the user
	# @param key key of criteria in config file
	def load_labels(key)
		if Cfg.has_key? key
			Cfg[key].each do |meth, crit|
				@name_crits[meth] = crit == nil ? create_label(meth.to_s) : crit
			end
		end		
	end

	# Create label for method in params
	# @param meth [String] method linked to the label
	# @return [String] Renamed Label inspired of the name of the method
	def create_label(meth)
		meth.split('_').each {|s| s.capitalize! }.join(' ')
	end

end