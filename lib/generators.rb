#
# @Author Renan Strauss
#
# The intermediate (or final,
# it depends of the config)
# CSV file is needed
#
require 'csv'

module Generators
	#
	# Generates the CSV file
	#
	def prepare
		CSV.open(@cfg[:out] + '.csv', 'wb') do |f|
			# Criterias as columns
			f << @data.values.first.keys.unshift("projet").map! { |cri| Generator.titleize(cri.to_s) }

			# Values for each project as rows
			@data.keys.each do |proj|
				f << @data[proj].values.unshift(proj)
			end
		end
	end

	# Does nothing
	def csv
	end

	#
	# Generates an HTML file from
	# the CSV one
	#
	def html(ext = '.html')
		out = "<!DOCTYPE html><html><head>"
		out += "<link rel=\"stylesheet\" href=\"#{@cfg[:res_dir]}/css/component.css\" />"
		out += "<link rel=\"stylesheet\" href=\"#{@cfg[:res_dir]}/css/normalize.css\" />"
		out += '<script src="res/js/component.css"></script>'
		out += "</head><body><table><thead>"

		src = File.readlines(@cfg[:out] + '.csv')
		out += "  <tr><th>" + src.shift.strip.gsub(/\"/,"").gsub(/,$/,"").gsub(/,/,"</th><th>") + "</th></tr>\n"
		out += "</thead><tbody>"
		src.each do |line|
			out += "  <tr><td>" + line.strip.gsub(/\"/,"").gsub(/,$/,"").gsub(/,/,"</td><td>") + "</td></tr>\n"
		end
		out += "</tbody></table>"

		out += '<script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>'
		out += '<script src="http://cdnjs.cloudflare.com/ajax/libs/jquery-throttle-debounce/1.1/jquery.ba-throttle-debounce.min.js"></script>'
		out += "<script src=\"#{@cfg[:res_dir]}/js/jquery.stickyheader.js\"></script>"

		out += "</body></html>"

		File.open(@cfg[:out] + ext, 'w') { |f| f.write(out) }
	end
end