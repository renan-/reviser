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

require_relative '../lib/helpers/project'

module Reviser
	module Extensions
		module WebValidators
			include Helpers::Project

			#
			# FIXME : Dirty ?
			#
			def validate_web
				[:html, :css].each do |lang|
					validate lang, sources.select { |x| File.extname(x) == ".#{lang}" }
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
			def validate lang, files = sources
				results = {}
				files.each do |f|
					response = W3C::validate(lang, f)
					response.headers ||= []

					if response.headers.empty?
						results[f] = { :status => response.to_str }
					else
						results[f] = {
							:status => response.headers.has_key?(:x_w3c_validator_status) && response.headers[:x_w3c_validator_status] || 'Error',
							:errors => response.headers.has_key?(:x_w3c_validator_errors) && response.headers[:x_w3c_validator_errors] || 'Error',
							:warnings => response.headers.has_key?(:x_w3c_validator_warnings) && response.headers[:x_w3c_validator_warnings] || 'Error'
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
						# But it only works for HTML analysis, because jigsaw uses
						# includes 
						#
						body.sub! '@import "./style/base";', File.read(Cfg::resource 'css/web_validators/w3c-base.css')
						body.sub! '@import "./style/results";', File.read(Cfg::resource 'css/web_validators/w3c-results.css')

						body.sub! 'style/base.css', Cfg::resource('css/web_validators/w3c-base.css').to_path
						body.sub! 'style/results.css', Cfg::resource('css/web_validators/w3c-results.css').to_path

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
					rescue Object => e
						e.to_s
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