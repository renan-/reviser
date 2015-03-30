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
		# We get the HTML output
		#
		@data.each do |project, results|
			results.each do |criterion, value|
				@data[project][criterion] = value.html
			end
		end
	end

	def run
		out = '<!DOCTYPE html><html><head>'
		out += '<meta charset= "UTF-8">'
		out += "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{resource('css/jquery.dataTables.css').to_path}\">"
		out += "<script type=\"text/javascript\" src=\"#{resource('js/jquery-1.11.1.min.js').to_path}\"></script>"
		out += "<script type=\"text/javascript\" src=\"#{resource('js/jquery.dataTables.min.js').to_path}\"></script>"
		out += '<title>Results</title>'
		out += "</head>\n<body><table id=\"results\"><thead><tr>"

		@data.values.first.keys.unshift.unshift('Projet').each { |crit| out += "<th>#{crit}</th>" }
		
		out += '</tr></thead><tbody>'
 		# Values for each project as rows
		@data.keys.each do |proj|
			out += "<tr><th>#{proj}</th>"
			@data[proj].each do |k, v|
				out += "<td><pre>#{v.to_s.strip.scrub}</pre></td>"
			end
			out += '</tr>'
		end

		out += '</tbody></table>'
		out += "<script type=\"text/javascript\">"
		out += "$(document).ready(function() { $('#results').DataTable(); });"
		out += "</script>"
		out += '</body></html>'

    File.open('my_results.html', 'w') { |f| f.write(out) }
  end
end