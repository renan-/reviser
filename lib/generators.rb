require 'csv'
require 'spreadsheet'

# Module containing all methods
# for writing results.
# @author Renan Strauss
# @author Yann Prono
#
module Generators
	
	# Generates the CSV file
	def csv
		CSV.open(@cfg[:out] + '.csv', 'wb') do |f|
			# Criterias as columns
			f << (criterias).unshift("projet")

			# Values for each project as rows
			@data.keys.each do |proj|
				f << @data[proj].values.unshift(proj)
			end
		end
	end

	# Generates a Excel file
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

	# Generates an HTML file 
	def html(ext = '.html')
		out = "<!DOCTYPE html><html><head>"
		out += "<link rel=\"stylesheet\" href=\"#{@cfg[:res_dir]}/css/component.css\" />"
		out += "<link rel=\"stylesheet\" href=\"#{@cfg[:res_dir]}/css/normalize.css\" />"
		out += '<script src="res/js/component.css"></script>'
		out += '<title>Resultas</title>'
		out += "</head>\n<body><table><thead>"
		out += "  <tr>"

		criterias.unshift("Projets").each { |crit|out += "<th>#{crit}</th>" }
		
		out += "</tr></thead><tbody>"
 		# Values for each project as rows
		@data.keys.each do |proj|
			out += "<tr>"
			(@data[proj].values.unshift(proj)).each {|r| out += "<td>#{r}</td>"}
			out += "</tr>"
		end

		out += "</tbody></table>"

		out += '<script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>'
		out += '<script src="http://cdnjs.cloudflare.com/ajax/libs/jquery-throttle-debounce/1.1/jquery.ba-throttle-debounce.min.js"></script>'
		out += "<script src=\"#{@cfg[:res_dir]}/js/jquery.stickyheader.js\"></script>"

		out += "</body></html>"		

		File.open(@cfg[:out] + ext, 'w') { |f| f.write(out) }
	end
end