require 'csv'

class Generator < Component
	def initialize(data)
		super data
	end

	def run
		CSV.open(@cfg[:out], 'wb') do |f|
			# Criterias as columns
			f << @data.values.first.keys.unshift("projet").map! { |cri| Generator.titleize(cri.to_s) }

			# Values for each project as rows
			@data.keys.each do |proj|
				f << @data[proj].values.unshift(proj)
			end
		end
	end

	#
	# Quite handy
	#
	def self.titleize(str)
		str.split(/\_/).join(" ").capitalize
	end
end