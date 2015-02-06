require_relative 'app/exec'

%w(checker reviser config).each do |lib|
	require_relative "app/#{lib}"
end


# This class is the interface between program and the user.
# It enable to use the programm in command line.
#
# @author Yann Prono
class App

	# Include the module for command line
	include Exec
end
