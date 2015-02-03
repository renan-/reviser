#
# @Author Renan Strauss
#
# Basic stuff needed for Checker
#

module CodeAnalysisTools

	#
	# @return all the files in the project's folder
	#
	def files
		Dir.glob("**/*").select { |f| (File.file?(f)) }
	end

	#
	# @return all files matching the 
	# 		  extenstion language list (note that Cfg[:extension] must be an array)
	#
	def src_files
		files.select { |f| Cfg[:extension].include? File.extname(f) }
	end

	#
	# @return the total amount of lines of code
	#
	def lines_count
		count = src_files.inject(0) { |sum, f|
			sum + File.open(f).readlines.select { |l| !l.chomp.empty? }.size
		}

		count - comments_count # FIXME
	end

	#
	# @return the number of lines of comments
	#
	def comments_count
		tab_comments = src_files.inject([]) { |t, f| t << IO.read(f).scrub.scan(Cfg[:regex_comments]) }
		lines = tab_comments.inject("") { |s, comm| s << find_comments(comm) }.split "\n"

		lines.size
	end

private

	def find_comments(comm)
		comm.inject("") { |t, l| t << l.detect { |a| (a != nil) && !a.strip.empty? } + "\n" }
	end
end