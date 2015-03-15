require 'html5_validator/validator'

module HtmlValidator
	def validate_html
		validator = Html5Validator::Validator.new

		results = {}
		# Might need to take care of other extensions
		Dir['*.html'].each do |f|
			validator.validate_text File.read(f)
			results.store f, validator.errors
		end

		results
	end
end