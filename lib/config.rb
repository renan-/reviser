#
# @author Renan Strauss
# Externalises the Cfguration
# so that we don't always use
# "@cfg[:Cfg_field_with_a_very_long_name]"
#

class Cfg
	@@loaded = false

	def self.[](key)
		@@mem[key] unless !@@loaded
	end

	# @return true if there is the key in the config
	def self.has(key)
		@@mem.has_key? key
	end

	def self.load(cfg_file)
		@@loaded = true
		@@mem = {}

		populate YAML.load(File.read(cfg_file))
		sort_cfg = YAML.load(File.read(File.join(File.dirname(File.dirname(__FILE__)),
			'sort',"#{@@mem[:sort]}.yml")))

		populate YAML.load(File.read(File.join(File.dirname(File.dirname(__FILE__)),
			'lang',"#{sort_cfg['language']}.yml")))
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