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
# @author Renan Strauss
#
module CriteriaHelper

	attr_reader :criteria
	attr_reader :output

	# All criterias available.
	# :criterion => Name of the module
	@criteria

	# :criterion => label of criterion
	@output

	# Current directory of this file
	PWD = File.dirname __FILE__

	# Path of extensions
	EXT = File.join File.dirname(PWD), 'ext'

	# Path of label file
	LABELS = File.join File.dirname(PWD), 'labels.yml'

	# Enable to call a specified method.
	# @param meth [String] Method to call.
	# @return results of the method.
	def call meth
		if @criteria.key? meth
			@logger.info { "Include methods of #{@criteria[meth]}" } unless respond_to? meth
			self.class.send(:include, @criteria[meth]) unless respond_to? meth

			send meth 
		else
			nil
		end
	end


protected

	# Get all criteria which can be used.
	# @return [Array] all criteria
	def all
		@criteria.keys.map &:to_sym
	end

	#  from Cfg file to symbols
	# @param criterion The criteria
	# @param module_name The name of the module.
	def populate criterion, module_name
		raise "Criterion '#{criterion}' is already defined in #{@criteria[criterion.to_sym]} (#{criterion}/#{module_name}).\nPlease change the name of the method in one of modules." if @criteria.has_key? criterion.to_sym
		@criteria[criterion.to_sym] = module_name
	end

	# Load all of modules available for the analysis
	# @param directory Directory where search of modules is done.
	# @param regex regex to find name of modules.
	def load directory, regex = '*'
		modules =  Dir[File.join(directory, regex)]

		modules.each do |m|
			require_relative m
			ext = File.extname m
			module_name = Object.const_get "#{camelize(File.basename(m,ext))}", false
			@logger.info { "Load #{module_name}" }
			methods = module_name.instance_methods false
			methods.each { |method| populate(method, module_name) }
 		end	
 	end

	# Gets the name of module 
	# @param file_module Name of the file module.
	def camelize file_module
		file_module.split('_').each {|s| s.capitalize! }.join('')
	end

	# Load labels given by the user.
	# If the label doesn't exist, it will created with the name of the method.
	# @param key Key of criteria in config file
	def load_labels key 
		labels = YAML.load File.read LABELS
		if Cfg.has_key?(key) && Cfg[key].respond_to?('each')
			Cfg[key].each do |meth, label|
				# label not redefined ?          take label into labels.yml  if it is present 	          else create it !
				label = label == nil ? ((labels.respond_to?('[]') && labels.key?(meth)) ? labels[meth] : create_label(meth) ) : label
				@output[meth] = label
			end
		end
	end

	# Create label for a method.
	# @param meth [String] method linked to the label
	# @return [String] Renamed Label inspired of the name of the method
	def create_label meth
		meth.to_s.split('_').each {|s| s.capitalize! }.join(' ')
	end

end