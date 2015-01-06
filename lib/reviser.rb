class Reviser
	@@loadedComponents = {}

	def self.load(data)
		@@loadedComponents[data[:component]] = {inputFrom: data[:inputFrom], data: nil}
	end

	def self.run
		@@loadedComponents.each do |comp, conf|
			puts "Running #{Reviser.titleize comp} with config #{conf}"

			require_relative "#{comp}"
			c = eval("#{Reviser.titleize comp}").new ((conf[:inputFrom] != nil) && @@loadedComponents[conf[:inputFrom]][:data]) || nil

			@@loadedComponents[comp][:data] = c.run
			puts
		end
	end

	def self.titleize(str)
	  str.split(/ |\_/).map(&:capitalize).join("")
	end
end