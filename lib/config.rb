#
# @author Renan Strauss
# Externalises the configuration
#
require 'yaml'

module Reviser
	class Cfg
		# Path for specialized config files for projects
		ROOT = File.join(File.dirname(File.dirname(__FILE__)))

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
		# @returns The specified resource path
		# TODO : put resources in dedicated folders
		# for each component or extension, so that
		# the user can omit <lang>/<ext_name>/ when
		# calling this method
		#
		def self.resource path
			abs = File.join(ROOT, Cfg[:res_dir], path)
			File.new abs if File.exists? abs
		end

		# Method class alias
		# might remove this at some point ( sorry Yannou I know u worked hard :( )
		self.singleton_class.send(:alias_method, :=~, :has_key?)

		def self.load(cfg_file)
			@@loaded = true
			@@mem = {}

			populate YAML.load(File.read(cfg_file))
			type_file = File.join(ROOT,'type',"#{@@mem[:type]}.yml")
			type_cfg  = YAML.load(File.read(type_file))
			populate YAML.load(File.read(File.join(ROOT,'lang',"#{type_cfg['language']}.yml")))
			# So that project's type Cfg overrides
			# lang Cfg
			populate type_cfg
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