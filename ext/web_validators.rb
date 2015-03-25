#
# @author Renan Strauss
#
# A tool to validate what we call web languages,
# in other words languages that can't be analysed
# by compilation nor by execution
# It's very simple at that point, but feel free to
# make the extension better :-)
#
require 'rest_client'

module Reviser
	module Extensions
		module WebValidators
			include Helpers::Project

			def validate_web
				results = validate(:html)
				results.merge! validate(:css)

				#
				# Always returns html formatted output...
				# We'd need something like Rails
				# respond_to do |format|
				# 	format.html { ... }
				#   format.csv { ... }
				# end
				# To override the default behavior
				#
				prettify results
			end

			def validate_html
				validate :html
			end

			def validate_css
				validate :css
			end

			private

			def prettify results
				return "" unless results.first
				headings = results.values.first.keys

				html = '<table><caption>WebValidators results</caption><tr><th>File</th>'
				headings.each { |heading| html << "<th>#{heading}</th>" }
				html << '</tr>'

				results.each do |file, data|
					html << '<tr>'
					html << "<th>#{file}</th>"
					data.values.each { |value| html << "<td>#{value}</td>" }
					html << '</tr>'
				end

				html << '</table>'

				html
			end

			#
			# @returns a hash matching all files for this lang to a resultset
			#
			def validate lang
				results = {}

				files = sources.select { |s| File.extname(s) == ".#{lang}" }
				files.each do |f|
					response = W3C::validate(lang, f)

					if response.is_a?(Hash) && response.has_key?(:exception)
						results[f] = { :status => response[:exception].to_s }
					else
						results[f] = {
							:status => response.headers.has_key?(:x_w3c_validator_status) && response.headers[:x_w3c_validator_status] || 'Not available',
							:errors => response.headers.has_key?(:x_w3c_validator_errors) && response.headers[:x_w3c_validator_errors] || 'Not available',
							:warnings => response.headers.has_key?(:x_w3c_validator_warnings) && response.headers[:x_w3c_validator_warnings] || 'Not available'
						}
					end

					puts "\t\t#{f} => #{results[f][:status]}"

					#
					# Generate a file
					# Simply add 'web_validators_save_results: true'
					# in your project's type config file
					#
					Cfg[:web_validators_save_results] ||= false

					#
					# We generate only if config key is set and
					# response is not a raw string
					#
					if Cfg[:web_validators_save_results] and not response.headers.empty?
						body = response.to_str
						#
						# W3C uses scss so we need to replace imports by the
						# actual css...
						#
						case lang
						when :html
							body.sub! '@import "./style/base";', File.read(Cfg::resource 'css/web_validators/html-base.css')
							body.sub! '@import "./style/results";', File.read(Cfg::resource 'css/web_validators/html-results.css')
						when :css
							body.sub! 'style/base.css', Cfg::resource('css/web_validators/css-base.css').to_path
							body.sub! 'style/results.css', Cfg::resource('css/web_validators/css-results.css').to_path

							body.sub! 'file://localhost/TextArea', f
						end

						File.open(f + '.WEB_VALIDATORS.html', 'w') { |x| x.write body }
					end
				end

				results
			end

			#
			# This class is wrapping up
			# W3C API
			#
			class W3C
				VALIDATORS = {
					:html => 'validator.w3.org/check',
					:css  => 'jigsaw.w3.org/css-validator/validator'
				}

				#
				# @returns responses from the request made to the validator
				#
				def self::validate lang, file
					raise ArgumentError unless VALIDATORS.include? lang
					#
					# W3C is a free service and we shall not overflow it
					# with our requests so accordingly to their doc,
					# we sleep 1s between each request
					#
					sleep 1
					begin
						send lang, file
					rescue => e
						{ exception: e }
					end
				end

				#
				# W3C HTML Validator API expects a POST uploaded_file
				#
				def self::html file
					RestClient.post(VALIDATORS[:html], :uploaded_file => File.new(file))
				end

				#
				# Whereas W3C CSS Validator API doesn't accept uploaded
				# files, so we need to pass the raw text
				def self::css file
					RestClient.get(VALIDATORS[:css] + '?text=' + CGI.escape(File.read(file)))
				end
			end
		end
	end
end