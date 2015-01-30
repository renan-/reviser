
require_relative 'component'
require_relative 'generators'

class Generator < Component
	include Generators

	def initialize(data)
		super data
	end

	def run
		prepare

		begin
			send @cfg[:out_format].to_sym
		rescue
			'Wrong format'
		end
	end

	#
	# Quite handy
	#
	def self.titleize(str)
		str.split(/\_/).join(" ").capitalize
	end
end

#Component::setup '../config.yml'
#g = Generator.new nil
#Dir.chdir('../') {g.html}