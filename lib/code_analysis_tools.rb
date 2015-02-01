#
# @Author Renan Strauss
#
# Basic stuff needed for Checker
#

module CodeAnalysisTools

	def files
		Dir.glob("**/*").select { |f| (File.file?(f)) }
	end

	def src_files
		files.select { |f| @cfg[:extension].include? File.extname(f) }
	end

	def lines_count
		count = src_files.inject(0) { |sum, f|
			sum + File.open(f).readlines.select { |l| !l.chomp.empty? }.size
		}

		count - comments_count # FIXME
	end

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