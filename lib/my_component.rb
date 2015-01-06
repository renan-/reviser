#
# Pour vous montrer l'intérêt ;)
#
class MyComponent < Component
	def initialize(data)
		super data
	end

	def run
		puts "MyComponent running..."
		puts "Got this config : #{@Cfg}"
		puts "Got this data   : #{@data}"
	end
end