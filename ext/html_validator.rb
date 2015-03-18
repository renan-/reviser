require 'html5_validator/validator'

module Extensions
	module HtmlValidator
		include Helpers::CodeAnalysis
		
		def validate_html
			validator = Html5Validator::Validator.new

			results = {}
			# Might need to take care of other extensions
			sources.each do |f|
				validator.validate_text File.read(f)
				results.store f, validator.errors
			end

			results
		end
	end

end