#
# @author Renan Strauss
#
# A tool to validate what we call web languages,
# in other words languages that can't be analysed
# by compilation nor by execution
# It's very simple at that point, but feel free to
# make the extension better :-)
#
require 'w3c_validators'

module Reviser
	module Extensions
		module WebValidators
			include Helpers::Project
			include W3CValidators

			def validate_web
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

			def validate_html
				validate :html
			end

			def validate_css
				validate :css
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
					validator = MarkupValidator.new
				when :css
					validator = CSSValidator.new
				end

				raise ArgumentError unless validator != nil

				files = sources.select { |s| File.extname(s) == ".#{lang}" }
				files.each do |f|
					begin
						response = validator.validate_file(File.new(f))
						results[f] = {
							:valid => response.errors.length == 0,
							:errors => response.errors.length
						}

						puts "\t\t#{f} => #{results[f][:valid]}"
					rescue ValidatorUnavailable => e
						results[f] = e.message
					rescue Exception => e
						results[f] = e.message
					end
				end

				results
			end

			def prettify results
				return results unless results.values.first

				headings = results.values.first.keys

				html = '<table><tr><th>File</th>'
				headings.each { |heading| html << "<th>#{heading.to_s.capitalize!}</th>" }
				html << '</tr>'

				results.each do |file, data|
					html << "<tr><th>#{file}</th>"
					if data.is_a?(Hash)
						data.values.each { |value| html << "<td>#{value}</td>" }
					else
						html << "<td>#{data}</td>"
					end
					html << '</tr>'
				end
				html << '</table>'

				html
			end
		end
	end
end