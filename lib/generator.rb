require 'csv'

class Generator < Component
	def initialize(data)
		super data
	end

	def run
		CSV.open(@Cfg[:results], 'wb') do |f|
			# Criterias as columns
			f << @data.values.first.keys.unshift("Projet")

			# Values for each project as rows
			@data.keys.each do |proj|
				f << @data[proj].values.unshift(proj)
			end
		end
	end
end