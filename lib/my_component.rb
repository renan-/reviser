#
# Pour vous montrer l'intérêt ;)
#
class MyComponent < Component
	def initialize(data)
		super data
	end

	def run
		puts "MyComponent running..."
		puts "Got this data : #{@data}"
		puts "Returning 'Hello World!' to the next component that will be executed"

		return 'Hello World!'
	end
end