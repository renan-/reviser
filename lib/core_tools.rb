# Provide important methods
# for compilation or something like that.
#
# @author Yann Prono
module CoreTools
	#
	# For interpreted languages
	# We only check for missing files
	#
	def prepare
		missing_files.empty? && 'None' || res
	end

	# Check if the project has all files needed
	def missing_files
		return [] unless Cfg =~ :required_files

		dir = Dir['*']

		#
		# Check if there is any regexp
		# If it's the case, if any file
		# matches, we delete the entry
		# for diff to work properly
		#
		Cfg[:required_files].each_with_index do |e, i|
			if dir.any? { |f| (e.respond_to?(:match)) && (e =~ f) }
				Cfg[:required_files].delete_at i
			end
		end

		Cfg[:required_files] - dir
	end

	#
	# Executes the given command
	# and kills it if its execution
	# time > timeout
	# @returns stdout, stderr & process_status
	#
	def exec_with_timeout(cmd, timeout = Cfg[:timeout])
		stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
		process_status = -1

		stdin.close
		#
		# We try to wait for the thread to join
		# during the given timeout.
		# When the thread has joined, process_status
		# will be an object, so we can check and
		# return at the end if it failed to complete
		# before time runs out.
		#
		begin
			Timeout.timeout(timeout) do
				process_status = wait_thr.value
			end
		rescue Timeout::Error
			#
			# Then whether it suceeded or not,
			# we kill the process
			#
			begin
				Process.kill('KILL', wait_thr[:pid])
			rescue Object => e
				$stderr << "Unable to kill process : #{e.to_s}"
			end
		end

		result = {
			:stdout => process_status == -1 && 'Timeout' || stdout.read,
			:stderr => process_status == -1 && 'Timeout' || stderr.read,
			:process_status => process_status == -1 && 'Timeout' || process_status
		}
		
		result.delete :process_status unless process_status != -1

		stdout.close
		stderr.close

		result
	end

end