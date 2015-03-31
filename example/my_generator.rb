#
# This is a simple component showing how to extend Reviser
# We are going to build a custom HTML generator with jQuery :-)
#
require_relative '../lib/reviser'

class MyGenerator < Reviser::Component
	#
	# We're expecting results from Checker as data
	#
	def initialize data
		super data
		#
		# We want the HTML output
		#
		@data.each do |project, results|
			results.each do |criterion, value|
				@data[project][criterion] = value.html
			end
		end
	end

	def run
		#
		# Get our template file
		#
		template = resource('html/results_template.html').read

		out = '<thead><tr>'
		#
		# Each criterion as headings
		#
		@data.values.first.keys.unshift.unshift('Projet').each { |crit| out += "<th>#{crit}</th>" }
		
		out += '</tr></thead><tbody>'
 		# Values for each project as rows
		@data.keys.each do |proj|
			out += "<tr><th>#{proj}</th>"
			@data[proj].each do |k, v|
				out += "<td>#{v.to_s.strip}</td>"
			end
			out += '</tr>'
		end
		out += '</tbody>'

		#
		# Kind of a hacky template engine
		# We replace placeholders with actual values
		#
		template.sub! '[DATA]', out
		template.sub! '[MAINCSS_PATH]', resource('css/main.css').to_path

		File.open('my_results.html', 'w') { |f| f.write template }
  end
end