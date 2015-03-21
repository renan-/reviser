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
				validate :html, sources.select { |x| File.extname(x) =~ /(html)/ }
				validate :css, sources.select { |x| File.extname(x) =~ /(css)/ }
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
					headers = W3C::validate(lang, f)

					if headers.respond_to? 'each'
						results[f] = {
							:status => headers.has_key?(:x_w3c_validator_status) && headers[:x_w3c_validator_status] || 'Error',
							:errors => headers.has_key?(:x_w3c_validator_errors) && headers[:x_w3c_validator_errors] || 'Error',
							:warnings => headers.has_key?(:x_w3c_validator_warnings) && headers[:x_w3c_validator_warnings] || 'Error'
						}
					else
						results[f] = { :status => headers }
					end
					puts "\t\t#{f} => #{results[f][:status]}"
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
				# Atm this only
				# @returns headers from request to validator
				# We could as well get the response body (html by default)
				# and save that into a file.
				# Tell me what's best to do in your opinion
				#
				def self::validate lang, file
					raise ArgumentError unless VALIDATORS.include? lang

					begin
						response = RestClient.post(VALIDATORS[lang],:uploaded_file => File.new(file))
						response.headers
					rescue Object => e
						e.to_s
					end
				end
			end
		end
	end
end