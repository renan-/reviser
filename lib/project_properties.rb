#
# This modules is used to get all students who worked 
# in the project, thanks to convention given by teachers (config file).

# @author Yann Prono
module ProjectProperties

	# Dictionnary for regex in config file
	SYMBOLS = {
		:group 	=> 'GROUP',
		:firstname 	=> 'FIRSTN',
		:name 	=> 'NAME',
		:user 	=> 'USER',
		:lambda	=>	'LAMBDA'
	}

	# Regex to associate, depending the used word in Cfg
	REGEX = {
		:group 	=> '([A-Za-z0-9]+)',
		:firstname 	=> '([A-Za-z\-]+)',
		:name 	=> '([A-Za-z]+)', 
		:user 	=> '([^_]*)',
		:lambda 	=> '[a-zA-Z0-9 _]*',
	}

	# Get formatter written in the config file
	# And count occurences of  each word in the dictionnary SYMBOLS
	# @return Hash sym => count
	def analyze_formatter
		regex = Cfg[:projects_names]
		# Foreach known symbol
		SYMBOLS.each do |k, _|
			# Get numbers of occurences of the word k in regex 
			matches = regex.scan(SYMBOLS[k]).size
			# the word K => number of occurences
			@count[k] = matches if matches > 0
		end
	end

	# Analyze et get all informations 
	# that could be useful in the name of the
	# directory project.
	# @param entry Project to read
	def format entry
		ext = File.extname entry
		entry = File.basename entry, ext

		analyze_formatter if @count.empty?

    	group = check_entry_name entry
		generate_label group
	end

	# Generate new name of project
	# @param infos All informations used for 
	# generate a name for the directory.
	# @return String the formatted label
	def generate_label infos
		if !infos.empty?
			label = ''
			infos.reject{|k| k == :group }.each {|k,v| label += v.respond_to?('each') && v.each {|data| data +' ' } || v + ' ' }
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

	#
	# Apply regex of user on the entry name.
	# and try to get all interested matched values.
	def check_entry_name entry
		regex = Cfg[:projects_names]
		# who work on the current project (entry) ?
		position = get_position regex

		@count.each do |k, _|
			regex = regex.gsub SYMBOLS[k], REGEX[k]
		end
		
		# Apply created regex
		entry.match Regexp.new(regex)
		pos = 1
		infos = {}

		# Get matched values
		begin
			tmp = eval "$#{pos}"
			if tmp != nil
				infos[position[pos]] = tmp
			end
			pos += 1
		end while pos <= position.size
		sort_infos infos
		infos
	end

	# try to find all informations
	# about students which composed the group.
	# This method update array of students.
	# grp Array of matched informations
	def analyze_group grp
		formalized = []
		if @count.key? :firstname
			require 'enumerator'
			infos.each_slice(2) do |k,v|
				student = "#{k} #{v}"
				formalized << student
				@students << student
			end
			formalized
		else
			grp.each do |name|
				@students << name
			end
			grp
		end
	end

	# Put all datas found to respective variable
	# @param infos Informations found by regex
	def sort_infos infos
		@students << infos[:name]
		@groups << infos[:group]
		@binoms << infos[:name]
	end

end
