#
# This modules is used to get all students who worked 
# in the project, thanks to convention given by teachers (config file).

# @author Yann Prono
module ProjectProperties

	# Dictionnary for regex in config file
	SYMBOLS = {
		:class 	=> 'CLASS',
		:name_firstname 	=> 'NAME#FIRST',
		:name 	=> 'NAME',
		:user 	=> 'USER',
		:lambda	=>	'LAMBDA'
	}

	# Regex to associate, depending the used word in Cfg
	REGEX = {
		:class 	=> '([^_]*)',
		:name_firstname 	=> '([^_]* [^_]*)',
		:name 	=> '([^_]*)',
		:user 	=> '([^_]*)',
		:lambda 	=> '[a-zA-Z0-9 _]*',
	}

	# Get formatter written in the config file
	# And count occurences of  each word in the dictionnary SYMBOLS
	# @return Hash sym => count
	def analyze_formatter
		regex = Cfg[:projects_names]
		# Foreach known symbol
		SYMBOLS.each do |k,v|
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
		ext = File.extname(entry)
		entry = File.basename(entry, ext)
		puts entry

		analyze_formatter if @count.empty?
		nb_students = 0
		regex = Cfg[:projects_names]

		@count.each do |k,v|
			regex = regex.gsub(SYMBOLS[k], REGEX[k])
			nb_students += v if k == :name
		end

		# Apply created regex
		entry.match(Regexp.new(regex))
		group = []

		# Nomber of students is detected with the numbers of occurence of special words
		for i in 1..nb_students
			@students << eval("$#{i}")
			puts eval("$#{i}")
			group << eval("$#{i}")
		end
		
		@groups << group
		generate_label group
	end

	# Generate new name of project
	# @param infos All informations used for 
	# generate a name for the directory.
	# @return String the formatted label
	def generate_label infos
		label = ""
		infos.each {|i| label += label == "" ? i : " " + i }
		label
	end

end