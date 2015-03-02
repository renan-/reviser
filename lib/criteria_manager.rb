require_relative 'config'

# Manage criteria.
# Criteria Manager provides all criteria available.
# It's also managed labels of criterion
# To add a criterion, the user has to write in the config file
# all criteria he wants.
#
# Convention over configuration !
# Criteria manager imports automaticlly all ruby files 
# containing 'tool' in its filename.
# 
# @example Call a criterion (in the config File):
#   criteria:
#     - :count_lines: Number of lines
#     - :list_files: List of all files
#     - :<method>: <label of method>

# @example Write a module:
# Create a file with name as this regex '*tool.rb*' => 'my_module_tools.rb'
# header of this module :
# 	module MyModuleTools
#   ...
#	end
#
# @author Yann Prono
#
class CriteriaManager

	# All criterias available.
	# :criterion => Name of the module
	@criteria

	# :criterion => label of criterion
	@labels_crits

	# Current directory of this file
	PWD = File.dirname(__FILE__)

	# Path of extensions
	EXT = File.join(File.dirname(PWD), 'ext')

	def initialize
		@criteria = Hash.new
		@labels_crits = Hash.new
		load(PWD, '*tool*')
		load(EXT, '*')
		prepare :criteria
		load_labels :criteria
	end

	# @return criterion => label of criterion
	def criteria
		return @labels_crits
	end

	# Enable to call a specified method.
	# @param meth [String] Method to call.
	# @return results of the method.
	def call(meth)
		if @criteria.key? meth
			self.class.send(:include, @criteria[meth]) unless respond_to? meth
			var = send meth
		else
			nil
		end
	end


	# Prepare all criterias provided by the user in the config file.
	# @param key key of config file
	def prepare(key)

		if Cfg.has_key? key
			# Diff between modules of app and input of user
			unknown_modules = (Cfg[key].keys.map &:to_sym) - all

			# Get all criterias to delete
			to_delete = Cfg[key].empty? ? {} : all - (Cfg[key].keys.map &:to_sym)
			to_delete = to_delete + unknown_modules

			# Delete now !
			to_delete.each {|crit| @criteria.delete(crit.to_sym)}
		end
	end


	private 

	# Get all criteria which can be used.
	# @return [Array] all criteria
	def all
		@criteria.keys.map &:to_sym
	end

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
			module_name = Object.const_get("#{camelize(File.basename(m,ext))}")
			methods = module_name.instance_methods
			methods.each { |method| populate(method, module_name) }
 		end	
 	end

	# Gets the name of module 
	# @param file_module Name of the file module.
	def camelize(file_module) 
		file_module.split('_').each {|s| s.capitalize! }.join('')
	end

	# Load labels given by the user.
	# If the label doesn't exist, it will created with the name of the method.
	# @param key Key of criteria in config file
	def load_labels(key)
		if Cfg.has_key? key
			Cfg[key].each do |meth, label|
				# only if meth is loaded in @criteria
				@labels_crits[meth] = (label == nil ? create_label(meth.to_s) : label) if @criteria.key? meth
			end
		end		
	end

	# Create label for a method.
	# @param meth [String] method linked to the label
	# @return [String] Renamed Label inspired of the name of the method
	def create_label(meth)
		meth.split('_').each {|s| s.capitalize! }.join(' ')
	end

end