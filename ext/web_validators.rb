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
				#
				# TODO : explain the exception to the user
				#
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
						results[f] = e.message
					rescue Exception => e
						results[f] = e.message
					end
				end
				puts "]"

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