# Here all required files

require_relative 'app/exec'

%w(archiver organiser checker reviser generator).each do |lib|
	require_relative "app/#{lib}"
end


class App

	def initialize
	end

	include Exec
end
