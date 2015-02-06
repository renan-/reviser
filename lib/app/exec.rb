require 'fileutils'

module Exec

	def hello
		puts 'Hello, this is my app'
	end

	def exec(*argv)
		self.send(argv[0].first)
	end


	def init
		puts FileUtils.pwd
		puts 'Welcome in init'

		File.open('jfdkfkd','w')
	end
end