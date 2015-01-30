#
# @Author Renan Strauss
#
# The intermediate (or final,
# it depends of the config)
# CSV file is needed
#
require 'csv'
require 'spreadsheet'

module Generators
	#
	# Generates the CSV file
	#
	def prepare
		CSV.open(@cfg[:out] + '.csv', 'wb') do |f|
			# Criterias as columns
			f << (criterias).unshift("projet")

			# Values for each project as rows
			@data.keys.each do |proj|
				f << @data[proj].values.unshift(proj)
			end
		end
	end

	# Does nothing
	def csv
	end

	def xls
		Spreadsheet.client_encoding = 'UTF-8'
		book = Spreadsheet::Workbook.new
		sheet = book.create_worksheet :name => 'Results'

		# header
		format = Spreadsheet::Format.new :weight => :bold, :size => 14 , 
		:horizontal_align => :center

		(criterias.unshift("Projets")).each_with_index do |crit, i|
			sheet[0,i] = crit
			sheet.column(i).width = (crit.size * format.font.size/10) + 5
		end
		sheet.row(0).default_format = format
		sheet.row(0).height = 18

		# Values for each project as rows
		@data.keys.each_with_index do |proj, i|
			sheet.insert_row(i+1,@data[proj].values.unshift(proj))
		end
		book.write @cfg[:out] + '.' + @cfg[:out_format]
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