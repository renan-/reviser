#
# @Author Renan Strauss
#
# Basic stuff needed for Checker
#

module CodeAnalysisTools

	#
	# @returns all the files in the project's
	# 		   folder
	#
	def files
		Dir.glob("**/*").select { |f| (File.file?(f)) }
	end

	#
	# @returns all files matching the 
	#		   extenstion language
	# 		   list (note that @cfg[:extension]
	# 		   must be an array)
	#
	def src_files
		files.select { |f| @cfg[:extension].include? File.extname(f) }
	end

	#
	# @returns the total amount of lines of code
	#
	def lines_count
		count = src_files.inject(0) { |sum, f|
			sum + File.open(f).readlines.select { |l| !l.chomp.empty? }.size
		}

		count - comments_count # FIXME
	end

	#
	# @returns the number of lines of comments
	#
	# TODO : Make the code more readable,
	# 	     and fix the fact that it seems
	#        to return 1 more than the actual
	#        value
	#
	def comments_count
		src_files.inject([]) { |tab, f|
			tab << IO.read(f).scrub.scan(@cfg[:regex_comments])
		}.inject("") { |s, comm|
			s << comm.inject("") { |t, l|
				t << l.select { |a| (a != nil) && !a.strip.empty? }.join("\n")
			}
		}.split("\n").size
	end
end