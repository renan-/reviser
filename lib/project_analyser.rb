module Project_analyser
	
	SYMBOLES = {
		:class 	=> 'CLASS',
		:name 	=> 'NAME',
		:user 	=> 'USER',
	}

	# Get formatter written in the config file
	# And count occurences of dictionnary SYMBOLES
	# @return Hash sym => count
	def analyze_formatter
		regex = Cfg[:projects_names]		
		SYMBOLES.each do |k,v|
			matches = regex.scan(SYMBOLES[k]).size
			@count[k] = matches if matches > 0
		end
	end


	def format entry
		analyze_formatter if @count.empty?
		nb_students = 0
		regex = Cfg[:projects_names] + "\\.[a-z.]+"

		@count.each do |k,v|
			regex = regex.gsub(SYMBOLES[k],"([^_]*)")
			nb_students += v if k == :name
		end

		entry.match(Regexp.new(regex))
		group = []
		for i in 1..nb_students
			@students << eval("$#{i}")
			group << eval("$#{i}")
		end	
		@groups << group
	end

end