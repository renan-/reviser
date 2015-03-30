# Manage criteria and labels.

# @example Call a criterion (in the config File):
#   criteria:
#     - :count_lines: Number of lines
#     - :list_files: List of all files
#     - :<method>: <label of method>
#
# @author Yann Prono
# @author Renan Strauss
#
module Reviser
	module Helpers
		# This module enables to 
		# imports automaticlly all modules for the analysis
		#
		# Convention over configuration !
		# A analysis module contains the word 'tool' in its filename.
		# You also have the possibility to put code in the ext folder.
		#
		# @example Call a criterion during analysis (in the config File):
		#   criteria:
		#     - :count_lines
		#     - :list_files
		#     - :<method>: <custom label>
		#
		# In the last item of the list, the custom label will overwrite the label 
		# in labels.yml if it exist.
		# 
		module Criteria
			
			# Where I am ?	
			PWD = File.dirname __FILE__

			# Path of criteria
			CRITERIA = File.join File.dirname(PWD), 'criteria'
			# Path of extensions
			EXTENSIONS = File.join File.dirname(File.dirname(File.dirname(PWD))), 'ext'

			attr_reader :criteria
			attr_reader :output

			# All criterias available.
			# :criterion => Name of the module
			@criteria

			# :criterion => label of criterion
			@output

			# Enable to call a specified method.
			# @param meth [String] Method to call.
			# @return results of the method.
			def call meth
				if @criteria.key? meth
					@logger.h1(Logger::INFO, "Include methods of #{@criteria[meth]}") unless respond_to? meth
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
			def load_modules directory, regex = '*'
				@logger.h2 Logger::INFO, "Modules of #{directory}"
				modules =  Dir[File.join(directory, regex)]

				namespace = directory == EXTENSIONS && 'Reviser::Extensions' || 'Reviser::Criteria'
				modules.each do |m|
					require_relative m
					ext = File.extname m
					module_name = "#{namespace}::#{camelize(File.basename(m,ext))}"
					
					load_module_methods module_name
		 		end	
		 	end

		 	def load_module_methods module_name
					mod = Object.const_get module_name, false

					@logger.h3 Logger::INFO, "Load #{module_name}"

					methods = mod.instance_methods false
					methods.each { |method| populate(method, mod) }
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
				labels = Labels.load

				if Cfg.has_key?(key) && Cfg[key].respond_to?('each')
					Cfg[key].each do |meth|
						label = ((labels.respond_to?('each') && labels.key?(meth.to_sym))) && labels[meth.to_sym] || create_label(meth)
						@output[meth.to_sym] = label
					end
				end
			end

			# Create label for a method.
			# @param meth [String] method linked to the label
			# @return [String] Renamed Label inspired of the name of the method
			def create_label meth
				@logger.h2 Logger::ERROR, "Create label for #{meth}. You should custom your label (see 'reviser add')"
				meth.to_s.split('_').each {|s| s.capitalize! }.join(' ')
			end

			# Manage all actions for adding, updating or getting labels of Reviser.
			# A label is a a group of words, describing the associated criterion (method).
			#
			# @example  
			#  	criterion => label
			# 	all_files => all files of project
			#
			# known Labels are in the labels.yml file.
			#
			# @author Yann Prono
			module Labels

				# Current directory of this file
				PWD = File.dirname __FILE__

				# Path of label.yml file
				LABELS = File.join File.dirname(File.dirname(File.dirname(PWD))), 'labels.yml'

				#
				# Enable to associate a label to a criterion (method).
				# The label will be saved in the 'labels.yml' file
				# @param meth Method to link.
				# @param label Label to link with the method.
				def self.add meth, label
					res = "Create"
					labels = YAML.load File.open(LABELS)
					if labels.respond_to? '[]'
						res = "Update" if labels.key? meth
						labels[meth] = label
						File.open(LABELS, 'w') { |f| f.write labels.to_yaml }
					end
					res
				end

				# @return Hash all known labels by reviser.
				# :criterion => label
				def self.load
					Labels.populate(YAML.load(File.open(LABELS)))
				end

				def self.populate hash
					labels = {}
					if hash.respond_to?('each')
						hash.each do |meth, label|
							labels[meth.to_sym] = label
						end
					end
					labels
				end
			end
		end
	end
end