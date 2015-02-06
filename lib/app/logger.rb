require 'fileutils'

#
# Logger is a generator whichs logs
# actions of this program (archiver, organiser ...)
#
# @author Yann Prono
#
class Logger
	@@out_dir = 'logs'

	# Create and open the file
	# @param file_log [String] The file name of the file log
	def initialize(file_log)
		puts 'coucou' "file_log.class"
		#FileUtils.mkdir @@out_dir unless Dir.exist? @@out_dir
		#@fopen = File.open("#{File.join(@@out_dir, file_log)}+.txt", "w")
	end

	def header(msg)
		@fopen.print("\t*** ",msg," ***\n\n")
	end

	def footer(msg, close = false)
		@fopen.print("\n\t*** ",msg," ***\n\n")
	end

	# Puts a title into the log file
	# @param title [String] the title.
	def title(title)
		@fopen.print("\t\t","=" * (title.length+2),"\n")
		@fopen.print("\t\t"," #{title}","\n")
		@fopen.print("\t\t","=" * (title.length+2),"\n")
	end

	def subtitle(title)
		@fopen.print("\n\n\t","** #{title} **","\n\n")
	end

	# Adds a log.
	# @param msg [String] Log to add
	def log(msg, error = false)
		msg = error ? "### #{msg}" : "= #{msg}"
		@fopen.puts("#{msg}")
	end

	# Close the current log file
	def close
		@fopen.close
	end
end