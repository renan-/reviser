#
# This class represents an analysis result
# It allows us to easily output well-formatted results for certain output formats
# (eg HTML)
#
# @author Renan Strauss
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
		# When the user calls a method whose name is a valid format,
		# we associate it with the given block value if a block is given,
		# else we return the stored value
		#
		def method_missing m, *args, &block
			raise NoMethodError, "Unknown format #{m}" unless Cfg::OUT_FORMATS.include?(m)

			format = "@#{m}".to_sym

			block_given? && instance_variable_set(format, block[]) || instance_variable_get(format)
		end
	end
end