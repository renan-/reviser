
# Module containing all methods for writing results.
#
# Convention over configuration !
#
# To add a new format, you need maybe to install a gem.
# Find a gem which supports a specified format on rubygems.org.
# Add the line "gem <gem>" in the Gemfile and execute "bundle install"
#
# Now, you can write the method corresponding to the format.
# The name of the method corresponds to the format.
# For example, if you want to generate a word file (.doc), the name of the method will be: "doc"
# Don't forget to require the gem: "require <gem>" at the beginning of the method !
# the header of method looks like the following block:
#
#  		def <format> (ext = '<format>')
# 			require <gem>
# 			...
# 		end
#
# To write results, you have to go through in the data instance variable.
# data is a [Hash]:
# 		- key: 		The person's name.
#		- value: 	Results of analysis
#
# Each value of data is also a [Hash]:
# 		- key: 		the name of criterion checked.
#		- value: 	The result of criterion.
#
#
# @author Renan Strauss
# @author Yann Prono
#
module Reviser
	module Components
		module Generators
			
			# Generates the CSV file
			def csv(ext = '.csv')
				require 'csv'
				CSV.open(out(ext), 'wb') do |f|
					# Criterias as columns
					f << (criterias).unshift('projet')

					# Values for each project as rows
					@data.keys.each do |proj|
						f << @data[proj].values.unshift(proj)
					end
				end
			end

			# Generates a Excel file
			def xls(ext = '.xls')
				require 'spreadsheet'
				Spreadsheet.client_encoding = 'UTF-8'
				book = Spreadsheet::Workbook.new
				sheet = book.create_worksheet :name => 'Results'

				# header
				format = Spreadsheet::Format.new :weight => :bold, :size => 14 , 
				:horizontal_align => :center

				(criterias.unshift('Projets')).each_with_index do |crit, i|
					sheet[0,i] = crit
					sheet.column(i).width = (crit.size * format.font.size/10) + 5
				end
				sheet.row(0).default_format = format
				sheet.row(0).height = 18

				# Values for each project as rows
				@data.keys.each_with_index do |proj, i|
					sheet.insert_row(i+1,@data[proj].values.unshift(proj))
				end	

				book.write out(ext)
			end

			# Generates an HTML file 
			def html(ext = '.html')
				out = '<!DOCTYPE html><html><head>'
				out += '<meta charset= "UTF-8">'
				out += "<link rel=\"stylesheet\" href=\"#{Cfg[:res_dir]}/css/component.css\" />"
				out += "<link rel=\"stylesheet\" href=\"#{Cfg[:res_dir]}/css/normalize.css\" />"
				out += '<script src="res/js/component.css"></script>'
				out += '<title>Results</title>'
				out += "</head>\n<body><table><thead>"
				out += '  <tr>'

				criterias.unshift('Projet').each { |crit| out += "<th>#{crit}</th>" }
				
				out += '</tr></thead><tbody>'
		 		# Values for each project as rows
				@data.keys.each do |proj|
					out += "<tr><th>#{proj}</th>"
					@data[proj].each do |k, v|
						if k.to_s[/(compilation|execution)/]
							out += '<td class="console">'
						else 
							out += '<td>'
						end

						# If file, generate a link, else do nothing !
						out += file?(v) && "<pre><a href=\"#{v.gsub(' ','%20')}\" target=\"_blank\">#{v}</a></pre></td>" ||"<pre>#{v}</pre></td>"

					end
					out += '</tr>'
				end

				out += '</tbody></table>'

				out += '<script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>'
				out += '<script src="http://cdnjs.cloudflare.com/ajax/libs/jquery-throttle-debounce/1.1/jquery.ba-throttle-debounce.min.js"></script>'
				#out += "<script src=\"#{Cfg[:res_dir]}/js/jquery.stickyheader.js\"></script>"

				out += '</body></html>'

		    File.open(out(ext), 'w') { |f| f.write(out) }
			end

		private

			def out(ext)
				Cfg[:out] + ext
			end

			def file? path
				File.exist? path.to_s
			end

		end
	end
end