#
#   Reviser => a semi-automatic tool for student's projects evaluation
#
#   Copyright (C) 2015 Renan Strauss
#   Copyright (C) 2015 Yann Prono
#   Copyright (C) 2015 Romain Ruez
#   Copyright (C) 2015 Anthony Cerf
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
module Reviser
	module Components
		#
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
		#  		def <format> (ext = '<format>') require <gem>  ...  end
		#
		# To write results, you have to go through in the data instance variable.
		# data is a [Hash]:
		# 		
		#	- key: 		The person's name.
		#	- value: 	Results of analysis
		#
		# Each value of data is also a [Hash]:
		# 		
		#	- key: 		the name of criterion checked.
		#	- value: 	The result of criterion.
		#
		#
		# @author Renan Strauss
		# @author Yann Prono
		#
		module Generators
			
			# Generates the CSV file
			def csv data, ext = '.csv'
				require 'csv'
				CSV.open(out(ext), 'wb') do |f|
					# Criterias as columns
					f << (criterias).unshift('projet')

					# Values for each project as rows
					data.keys.each do |proj|
						f << data[proj].values.unshift(proj)
					end
				end
			end

			# Generates a Excel file
			def xls data, ext = '.xls'
				require_gem 'spreadsheet' unless defined? Spreadsheet

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
				data.keys.each_with_index do |proj, i|
					sheet.insert_row(i+1, data[proj].values.unshift(proj))
				end	

				book.write out(ext)
			end

			# Generates an HTML file 
			def html data, ext = '.html'
				out = '<!DOCTYPE html><html><head>'
				out += '<meta charset= "UTF-8">'
				out += "<link rel=\"stylesheet\" href=\"#{Cfg.resource('reviser/css/component.css').to_path}\" />"
				out += "<link rel=\"stylesheet\" href=\"#{Cfg.resource('reviser/css/normalize.css').to_path}\" />"
				out += '<title>Results</title>'
				out += "</head>\n<body><table><thead><tr>"

				criterias.unshift('Projet').each { |crit| out += "<th>#{crit}</th>" }
				
				out += '</tr></thead><tbody>'
		 		# Values for each project as rows
				data.keys.each do |proj|
					out += "<tr><th>#{proj}</th>"
					data[proj].each do |k, v|
						out += "<td>#{v}</td>"
					end
					out += '</tr>'
				end

				out += '</tbody></table></body></html>'

		    File.open(out(ext), 'w') { |f| f.write(out) }
			end

		private

			def out(ext)
				Cfg[:out] + ext
			end

		end
	end
end