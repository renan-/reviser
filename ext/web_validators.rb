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

#
# @author Renan Strauss
#
# A tool to validate what we call web languages,
# in other words languages that can't be analysed
# by compilation nor by execution
# It's very simple at that point, but feel free to
# make the extension better :-)
#
module Reviser
	module Extensions
		module WebValidators
			include Helpers::Project

			#
			# Validates HTML and CSS
			# if any
			#
			def validate_web
				unless defined? W3CValidators
					require_gem 'w3c_validators'

					self.class.send(:include, W3CValidators)
				end

				results = validate(:html)
				results.merge! validate(:css)

				#
				# We want a pretty HTML output :-)
				# 
				manufacture do |format|
					format.html { prettify results }
					format.csv { results }
					format.xls { results }
				end
			end

			private
			#
			# @returns a hash matching all files for this lang to a resultset
			#
			def validate lang
				results = {}
				validator = nil
				case lang
				when :html
					validator = W3CValidators::MarkupValidator.new
				when :css
					validator = W3CValidators::CSSValidator.new
				end

				raise ArgumentError unless validator != nil

				print "\t\t#{lang.upcase}\t["
				files = sources.select { |s| File.extname(s) == ".#{lang}" }
				files.each do |f|
					begin
						response = validator.validate_file(File.new(f))
						results[f] = {
							:valid => response.errors.length == 0,
							:errors => response.errors.length
						}

						print "="
					rescue W3CValidators::ValidatorUnavailable => e
						results[f] = { valid: e.message, errors: 1 }
					rescue Exception => e
						results[f] = { valid: e.message, errors: 1 }
					end
				end
				puts "]"

				results
			end

			def prettify results
				html = '<table><tr><th>File</th>'
				results.values.first.keys.each { |heading| html << "<th>#{heading.to_s.capitalize!}</th>" }
				html << '</tr>'

				results.each do |file, data|
					html << "<tr><th>#{file}</th>"
					data.values.each { |value| html << "<td>#{value}</td>" }
					html << '</tr>'
				end
				html << '</table>'

				html
			end
		end
	end
end