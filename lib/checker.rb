#
# Author:: Renan Strauss
#

class Checker < Component
	def initialize(data)
		super data
	end

	def run
		return "Hello World! sent by me (the Checker)"
	end
end