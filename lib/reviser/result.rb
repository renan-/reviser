#
# This class represents an analysis result
# It allows us to easily output well-formatted results for certain output formats
# (eg HTML)
#
module Reviser
	class Result
		#
		# In case no call to manufacture was made,
		# Checker will create a result with the same
		# valeu for all formats
		#
		def initialize data = nil
			if data != nil
				Cfg[:out_format].each do |format|
					instance_variable_set("@#{format}".to_sym, data)
				end
			end
		end

		#
		# Does the magic ;-)
		#
		def method_missing m, *args, &block
			format = "@#{m}".to_sym

			if block_given?
				instance_variable_set(format, block.call)
			else
				instance_variable_get(format)
			end
		end
	end
end