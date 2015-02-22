#
# @author Renan Strauss
# Externalises the configuration
#
require 'yaml'

class Cfg

	# Path for specialized config files for projects
	@root = File.join(File.dirname(File.dirname(__FILE__)))

	# Is the config is loaded ?
	@@loaded = false

	def self.[](key)
    	@@mem[key] if @@loaded
	end

	# @return true if there is the key in the config
	def self.has_key?(key)
		@@mem.has_key? key
	end

	# Method class alias
	# might remove this at some point ( sorry Yannou I know u worked hard :( )
	self.singleton_class.send(:alias_method, :=~, :has_key?)

	def self.load(cfg_file)
		@@loaded = true
		@@mem = {}

		populate YAML.load(File.read(cfg_file))

		filename_sort = File.join(@root,'type',"#{@@mem[:sort]}.yml")
		sort_cfg = YAML.load(File.read(filename_sort))
		populate YAML.load(File.read(File.join(@root,'lang',"#{sort_cfg['language']}.yml")))
		# So that project's type Cfg overrides
		# lang Cfg
		populate sort_cfg
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