#
# Provide important methods
# for compilation or something like that.
#
# @author Renan Strauss
# @author Yann Prono
#
require_relative '../result'

module Reviser
	module Helpers
		module Project
			#
			# For interpreted languages
			# We only check for missing files
			#
			def prepare
				missing_files.empty? && 'None' || res
			end

			# Check if the project has all files needed
			def missing_files
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
			# @return all the files in the project's folder
			#
			def files
				Dir.glob("**/*").select { |f| (File.file?(f)) }
			end

			def sources
				files.select { |f| Cfg[:extension].include? File.extname(f) }
			end

			def manufacture &block
				format = Result.new
				block.call format

				format
			end

			# This modules is used to scan the name of project
			# in order to get all students who worked.
			# This analysis uses regex of convention given by teachers (config file).
			#
			# @author Yann Prono
			#

			module Naming

				# Dictionnary for regex in config file
				SYMBOLS = {
					:group 		=> 'GROUP',
					:firstname 	=> 'FIRSTN',
					:name 		=> 'NAME',
					:user		=> 'USER',
					:lambda		=> 'LAMBDA'
				}

				# Regex to associate, depending the used word in Cfg
				REGEX = {
					:group 		=> '([A-Za-z0-9]{3,4})',
					:firstname 	=> '([A-Za-z\-]+)',
					:name 		=> '([A-Za-z]+)',
					:user 		=> '([^_]*)',
					:lambda 	=> '[a-zA-Z0-9 _]*'
				}


				# Get formatter written in the config file
				# and count occurences of each word in the dictionnary SYMBOLS.
				# @return [Hash] sym => count.
				#
				def analyze_formatter
					regex = Cfg[:projects_names]
					# Foreach known symbols
					SYMBOLS.each do |k, _|
						# Get numbers of occurences of the word k in regex 
						matches = regex.scan(SYMBOLS[k]).size
						# the word K => number of occurences
						@count_patterns[k] = matches if matches > 0
					end
				end


				# Analyze et get all informations 
				# that could be useful in the name of the
				# directory project.
				# @param entry [String] name of directory to analysis.
				#
				def format entry
					ext = File.extname entry
					entry = File.basename entry, ext

					analyze_formatter if @count_patterns.empty?

			    	group = check_entry_name entry
					generate_label group
				end


				# Generate new name of project.
				# @param infos [Hash] All informations used for generate a name for the directory.
				# @return [String] the formatted name for directory project
				#
				def generate_label infos
					unless infos.empty?
						label = ''
						infos.reject { |k| k == :group }.each { |_, v|
							if v.respond_to?('each')
								v.each { |data|
								label += data +' '
							}
							else
								label += v + ' '
							end
						}
						# Inject group of project before name : group/name
						label = infos.key?(:group) && File.join(infos[:group], label) || label
						label
					end
				end

				# I'm not pround of this method ...
				# associate to a symbol, his position in the regex
				# @example NAME_FIRSTN
				# will give : {
				#	1 => :name,
				#	2 => :firstname
				#}
				def get_position regex
					res = {}
					SYMBOLS.each do |k,v|
						regex.scan(v) do |_|
							res[$~.offset(0)[0]] = k
						end
					end

					res = (res.sort_by { |k, _| k }).to_h
					tmp = {}

					index = 1
					res.each do |_,v|
						tmp[index] = v
						index += 1
					end
					tmp
				end


				# Apply regex of user on the entry name
				# and try to get all interested matched values.
				def check_entry_name entry
					regex = Cfg[:projects_names]
					# who work on the current project (entry) ?
					position = get_position regex

					@count_patterns.each do |k, _|
						regex = regex.gsub SYMBOLS[k], REGEX[k]
					end
					
					# Apply created regex
					entry.match Regexp.new(regex)
					pos = 1
					infos = {}

					# Get matched values
					begin
						tmp = eval "$#{pos}"
						if tmp != nil && tmp != ''
							tmp = tmp.delete '_'
							infos.has_key?(position[pos]) && infos[position[pos]] << tmp || infos[position[pos]] = [tmp]
						end
						pos += 1
					end while pos <= position.size

					if infos.empty?
						infos[:unknown] = entry
					end
					sort_infos infos
					infos
				end


				# Put all datas found in respective variables (students, groups, teams ...).
				# @param infos [Hash] Informations found by regex.
				def sort_infos infos
					if infos.has_key?(:name)
						infos[:name].respond_to?('each') && infos[:name].each { |n| @students << n } || @students << infos[:name] 
						@binoms << infos[:name]
					end
					if infos.has_key?(:group)
						infos[:group] = infos[:group][0].upcase
						sym_group = infos[:group].to_sym
						@projects_per_group[sym_group] = @projects_per_group.key?(sym_group) && @projects_per_group[sym_group] + 1 || 1 
					end
					
					@unknown << infos[:unknown] if infos.key? :unknown
				end


				def ask entry
				end

			end
		end
	end
end