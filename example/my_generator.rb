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
		out += "<link rel=\"stylesheet\" type=\"text/css\" href=\"http://netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css\">"
		out += "<link rel=\"stylesheet\" type=\"text/css\" href=\"http://cdn.datatables.net/plug-ins/f2c75b7247b/integration/bootstrap/3/dataTables.bootstrap.css\">"
		out += "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{resource('css/main.css').to_path}\">"
		out += "<script type=\"text/javascript\" src=\"http://code.jquery.com/jquery-1.10.2.min.js\"></script>"
		out += "<script type=\"text/javascript\" src=\"http://cdn.datatables.net/1.10.5/js/jquery.dataTables.min.js\"></script>"
		out += "<script type=\"text/javascript\" src=\"http://cdn.datatables.net/plug-ins/f2c75b7247b/integration/bootstrap/3/dataTables.bootstrap.js\"></script>"
		out += '<title>Results</title>'
		out += "<script type=\"text/javascript\">"
		out += "$(document).ready(function() { $('#results').dataTable({\"dom\":' <\"search\"fl><\"top\">rt<\"bottom\"ip><\"clear\">'}); });"
		out += "</script>"
		out += "</head>\n<body><table id=\"results\"><thead><tr>"

		@data.values.first.keys.unshift.unshift('Projet').each { |crit| out += "<th>#{crit}</th>" }
		
		out += '</tr></thead><tbody>'
 		# Values for each project as rows
		@data.keys.each do |proj|
			out += "<tr><th>#{proj}</th>"
			@data[proj].each do |k, v|
				out += "<td>#{v.to_s.strip.scrub}</td>"
			end
			out += '</tr>'
		end

		out += '</tbody></table>'
		out += "<script type=\"text/javascript\">"	
		out += "$('#results').removeClass( 'display' ).addClass('table table-striped table-bordered');"
		out += "</script>"
		out += '</body></html>'

    File.open('my_results.html', 'w') { |f| f.write(out) }
  end
end