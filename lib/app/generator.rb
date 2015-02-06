
require_relative 'component'
require_relative 'generators'

class Generator < Component
	include Generators

	def initialize(data)
		super data
	end

	def run
		begin
			if Cfg[:out_format].respond_to? 'each'
				Cfg[:out_format].each { |f| send f.to_sym }
			else
				send Cfg[:out_format].to_sym
			end
		rescue
			'Wrong format'
		end
	end

	# Get all criterias of marking
	# used to display informations in documents 
	# @return [Array] Array with all criterias.
	def criterias
		@data.values.first.keys.unshift.map! { |cri| Generator.titleize(cri.to_s) }
	end

	#
	# Quite handy
	#
	def self.titleize(str)
		str.split(/\_/).join(" ").capitalize
	end

	
end

#Component::setup '../Cfg.yml'
#g = Generator.new nil
#Dir.chdir('../') {g.html}