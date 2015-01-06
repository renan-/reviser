class Generator < Component
	def initialize(data)
		super data
	end

	def run
		puts "Got this data : #{@data}"
	end
end