#
# @author Renan Strauss
#
# A tool to validate what we call web languages,
# in other words languages which can't be analysed
# by compilation nor by execution
# It's very simple at that point, but feel free to
# make the extension better :-)
#
require 'rest_client'

module Extensions
	module WebValidators
		include Helpers::CodeAnalysis

		def validate_html
			results = {}
			sources.each do |f|
				headers = W3C::validate(:html, f)

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

		def css
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