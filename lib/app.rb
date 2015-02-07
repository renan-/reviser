require_relative 'app/exec'

%w(checker reviser config exec).each do |lib|
	require_relative "app/#{lib}"
end


# This class is the interface between program and the user.
# It enable to use the programm in command line.
#
# @author Yann Prono
class App

	
end