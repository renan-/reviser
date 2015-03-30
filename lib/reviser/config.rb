#
# Externalises the configuration
# Cfg acts like a hash whose entries are config keys
# associated with their values
#
# @author Renan Strauss
#
require 'yaml'

module Reviser
	class Cfg
		# Path for specialized config files for projects
		ROOT = File.join(File.dirname(File.dirname(File.dirname(__FILE__))))

		#
		# TODO : let the user dynamically add 
		# 			 his own directories
		#

		# Resources dir
		RES_DIR = 'res'
		# Project's type dir
		TYPE_DIR = 'type'

		# The available out formats
		OUT_FORMATS = [:csv, :html, :xls]

		# Is the config is loaded ?
		@@loaded = false

		def self.[](key)
	    @@mem[key] if @@loaded
		end

		def self.[]=(key, value)
			@@mem[key] = value if @@loaded
		end

		# @return true if there is the key in the config
		def self.has_key?(key)
			@@mem.has_key? key
		end

		#
		# @return The specified resource path
		# TODO : put resources in dedicated folders
		# for each component or extension, so that
		# the user can omit <lang>/<ext_name>/ when
		# calling this method
		#
		def self.resource path
			abs = File.join @@workspace_root, RES_DIR, path
			File.new abs if File.exists? abs
		end


		def self.load(cfg_file)
			@@mem = {}
			@@workspace_root = File.dirname(cfg_file)

			#
			# read our main config file
			#
			populate YAML.load(File.read(cfg_file))

			#
			# look for project's type
			type_file = File.join(@@workspace_root, TYPE_DIR, "#{@@mem[:type]}.yml")
			begin
				type_cfg  = YAML.load(File.read(type_file))
			rescue => e
				puts "File #{type_file} not found. Aborting..."
				exit
			end

			populate YAML.load(File.read(File.join(ROOT, 'lang', "#{type_cfg['language']}.yml")))
			# So that project's type Cfg overrides
			# lang Cfg
			populate type_cfg

			setup_defaults

			@@loaded = true
		end

		def self.setup_defaults
			#
			# Default values for optional keys
			#
			Cfg[:options] ||= { verbose: true, log_dir:'logs', log_mode: 'org' }
			Cfg[:timeout] ||= 4
			Cfg[:out] ||= 'results'
			Cfg[:out_format] ||= ['html', 'csv', 'xls']
			Cfg[:required_files] ||= []

			Cfg[:program_prefix] ||= ''
			Cfg[:execution_command] ||= ''
			Cfg[:execution_count] ||= 1

			Cfg[:create_git_repo] ||= false
		end

	private
		#
		# Handy method to convert string keys
		# read from Cfg file to symbols
		#
		def self.populate(hash)
			hash.each { |k, v| @@mem[k.to_sym] = v}
		end
	end
end