#
# @Author Renan Strauss
#
# Basic stuff needed for Checker
#

module Reviser
	module Criteria
		module CodeAnalysis
			include Helpers::Project

			def all_files
				files.join("\r")
			end

			#
			# @return all files matching the 
			# 		  extenstion language list (note that Cfg[:extension] must be an array)
			#
			def src_files
				sources.join("\r")
			end

			#
			# @return the total amount of lines of code
			#
			def lines_count
				count = sources.inject(0) { |sum, f|
					sum + File.open(f).readlines.select { |l| !l.chomp.empty? }.size
				}

				count - comments_count # FIXME
			end

			#
			# @return the number of lines of comments
			#
			def comments_count
				tab_comments = sources.inject([]) { |t, f| t << IO.read(f).scrub.scan(Cfg[:regex_comments]) }
				lines = tab_comments.inject('') { |s, comm| s << find_comments(comm) }.split "\n"

				lines.size
			end

			#
			# Translates a sub-match returned by scan
			# into raw comments string
			#
			def find_comments(comm)
				comm.inject('') { |t, l| t << l.detect { |a| (a != nil) && !a.strip.empty? } + "\n" }
			end
		end
	end
end