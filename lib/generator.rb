require 'csv'

class Generator < Component
	def initialize(data)
		super data
	end

	def run
		CSV.open(@Cfg[:results], 'wb') do |f|
			f << @data.keys.unshift(" ")
			#
			# There may be a better way than looping
			# through each project's results to get
			# all the values
			#
			@data.values.first.keys.each do |crit|
				vals = []
				@data.each do |proj, res|
					vals << res[crit]
				end

				f << vals.unshift(crit.to_s)
			end
		end
	end
end