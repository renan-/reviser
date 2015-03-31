Reviser
====================

###Description
---------------
[Reviser](https://rubygems.org/gems/reviser) is a semi-automatic tool for student's projects evaluation, written in Ruby.

###Installation
---------------

Download and install the gem with the following command line.

	gem install reviser


###Basic usage
---------------

To create a new workspace in the current directory, simply run the following command in a terminal: 


	reviser init .

	Create		res
	Create		type
	Create		config.yml
	Create		labels.yml

You see reviser has created *res* and *type/example* folders for you.
Now you'll have to customize *config.yml* to your own needs, and add a *type/your_project.yml*

To perform the analysis, simply run:

	reviser work

###How it works
---------------

Our tool is divided into 4 main components :

|Component|Role|
|-------------|-------|
|Archiver|Extracting all computing projects|
|Organiser|Parsing students names and renaming directories appropriately|
|Checker|Running the analysis based upon selected criteria and extensions|
|Generator|Generating the analysis results in various formats|

The basic idea is that each component can receive data from any of the components run before it.
It shall requests that input upon loading. The *work* command actually runs the above components
with the appropriate input data (e.g. *Generator* relies on *Checker* results).

###Configuration
---------------

This tool was thought to be very adaptable, thus it relies on YAML configuration files.

###Global configuration
Lives in *config.yml*.

|Key   |Description|Values|Required|
|------|-----------|-----|:--------:|
|*src*|Path to the archive containing projects||![checkbox.png](https://bitbucket.org/repo/AyGgAx/images/3281147034-checkbox.png)|
|*dest*|Path to a directory where projects will be extracted||![checkbox.png](https://bitbucket.org/repo/AyGgAx/images/3281147034-checkbox.png)|
|*projects_names*|Naming convention for projects|`^GROUP_NAME_NAME` `^GROUP_NAME(_NAME)*` `^TP_NAME_FIRSTN`|![checkbox.png](https://bitbucket.org/repo/AyGgAx/images/3281147034-checkbox.png)|
|*create_git_repo*|Whether to create a git repository for each project or not (requires *git* gem)|Default `false`||
|*type*|The type of the project|`my_project` (*type/my_project.yml* must exist)|![checkbox.png](https://bitbucket.org/repo/AyGgAx/images/3281147034-checkbox.png)|
|*criteria*|The criteria you want for analysis|`all_files` `src_files` `lines_count` `comments_count` `compile` `execute`|![checkbox.png](https://bitbucket.org/repo/AyGgAx/images/3281147034-checkbox.png)|
|*extensions*|The list of extensions you want for analysis|See below||
|*out*|The name of the analysis output file|Default *results*||
|*out_format*|The formats that will be generated|Default `csv` `html` (`xls` also available with *spreadsheet* gem)||
|*options*|A hash to set options|`:verbose` `:log_dir` `:log_mode`||

###Project configuration
Lives in *type/my_project.yml*.

|Key   |Description|Values|Required|
|------|-----------|-----|:--------:|
|*language*|The target language|`C` `Java` `HTML` `Ruby`|![checkbox.png](https://bitbucket.org/repo/AyGgAx/images/3281147034-checkbox.png)|
|*timeout*|In seconds. Compilation and execution will halt if not completed within the defined timeout|Default *4*||
|*required_files*|A list of required files|Tip: you can use regular expressions||
|*preferred_build_command*|The command to build the program with|`make`||
|*execute_command*|The name of the interpreter|`java` `ruby`||
|*program_prefix*|The program prefix|`pkg.` for Java||
|*program_name*|The name of the program|`a.out` `Main`||
|*execution_count*|The amount of times to execute the program|Default *1*||
|*execution_value*|The optional parameter to pass to the program when executing|A list of values whose length shall be *execution_count* or *1*. It can contains paths for files located in resources folder|||

###Labels configuration

Each criterion is associated with a label. A label is some words, describing the criterion's result. For example, a criterion which checks the existence of a Makefile could have a label like 'Existence of Makefile'.

By default, labels are generated with the name of the called method. You have the possibility to customize this label thanks to the command line tool:
	
	reviser add makefile? 'Existence of makefile'
	#            method       associated label

Labels are stored in your workspace, in a file called *labels.yml*.
You can also edit them by hand if you prefer.

###Extensions
Extensions are in fact Criteria we didn't want to include into reviser's core.
Reviser's core aims to rely as much as possible on native Ruby APIs to ensure its portability.
That's why Extensions exist: they basically are Criteria which relies on platform-spefic-features.

As of now, there are 2 extensions:

|Extension|Description|Add it to your workspace extensions|
|------------|--------------|----------------------------------------------|
|Valgrind|Runs a memcheck through system call to valgrind|`memleaks`|
|WebValidators|Validates HTML and CSS through W3C API calls|`validate_web`|

###Working on your own

If you have very special needs, you may need to create your own components or extensions.
You'll then need to load your components at the right time, and register your extensions for them to be available.

####Custom components

We're going to show you how to create a custom generator that will generate a nice-looking HTML table using jQuery dataTables.

*example/my_generator.rb*

``` ruby
#
# This is a simple component showing how to extend Reviser
# We are going to build a custom HTML generator with jQuery :-)
#
require 'reviser'

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
```

*example/res/my_generator/html/results_template.html*
``` html
<!DOCTYPE html>
<html>
	<head>
		<meta charset= "UTF-8">
		<link rel="stylesheet" type="text/css" href="http://netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css">
		<link rel="stylesheet" type="text/css" href="http://cdn.datatables.net/plug-ins/f2c75b7247b/integration/bootstrap/3/dataTables.bootstrap.css">
		<link rel="stylesheet" type="text/css" href="[MAINCSS_PATH]">
		<script type="text/javascript" src="http://code.jquery.com/jquery-1.10.2.min.js"></script>
		<script type="text/javascript" src="http://cdn.datatables.net/1.10.5/js/jquery.dataTables.min.js"></script>
		<script type="text/javascript" src="http://cdn.datatables.net/plug-ins/f2c75b7247b/integration/bootstrap/3/dataTables.bootstrap.js"></script>
		<title>My results</title>
		<script type="text/javascript">
			$(document).ready(function() {
				$('#results').dataTable({"dom":' <"search"fl><"top">rt<"bottom"ip><"clear">'});
			});
		</script>
	</head>
	<body>
		<table id="results">
			[DATA]
		</table>
		<script type="text/javascript">
			$('#results').removeClass('display').addClass('table table-striped table-bordered');
		</script>
	</body>
</html>
```

####Custom extensions

This file shows how to create a custom extension. It's as simple as creating a module.
In fact, when you register that module as an extension, its methods become available for you to add in *extensions* configuration key.

*example/my_extension.rb*

``` ruby
#
# A custom criteria for reviser
#
require 'reviser'

module MyExtension
	#
	# This helper has the 'sources' methods
	# that allow you to retrieve all sources
	# files (files matching language extension)
	#
	include Reviser::Helpers::Project

	def my_criteria
		results = []
		sources.each do |f|
			results << f
		end

		#
		# The manufacture method excepts
		# a block which must describe the result contents
		# for EACH format.
		# You can also return raw data, then it'll be as it is
		# for all formats.
		#
		manufacture do |format|
			format.html { to_html results }
			format.csv { ['This', 'is', 'power', 'of', 'Ruby', 'blocks'] }
			format.xls { results }
		end
	end

	private
		#
		# We just create a HTML list
		#
		def to_html data
			html = '<ul>'
			data.each do |el|
				html << "<li>#{el}</li>"
			end
			html << '</ul>'

			html
		end
end
```

### Putting it together
*example/config.yml*

``` yaml
extensions:
  - my_criteria
```

*example/my_app.rb*

This file shows how to plug your custom component into reviser's workflow as well as how to make your custom extension available.

``` ruby
require 'reviser'

require_relative 'my_extension'
require_relative 'my_generator'

module MyApp
	include Reviser

	def self.run config_file = 'config.yml'
		#
		# Setup reviser
		#
		Reviser::setup config_file

		#
		# You can now use MyExtension's methods for analysis
		#
		Reviser::register :extension => 'MyExtension'
		
		#
		# You can load any built-in component (archiver, organiser, checker, generator)
		# But be aware that they have to be ran in this order, and that
		# organiser takes input from archiver, checker from organiser and generator from checker
		# If you don't respect that, nothing will work.
		# But you can run your component at any step, this won't break the process.
		#
		Reviser::load :component => 'archiver'
		Reviser::load :component => 'organiser', :input_from => 'archiver'
		Reviser::load :component => 'checker', :input_from => 'organiser'
		#
		# We run our custom generator instead :-)
		#
		# With :local => true, we tell reviser not to look for our component
		# in its core ones but to let us include it ourselves instead
		#
		Reviser::load :component => 'my_generator', :input_from => 'checker', :local => true

		# Reviser::load :component => 'generator', :input_from => 'checker'

		#
		# Run reviser
		#
		Reviser::run
	end
end
```

*example/main.rb*

``` ruby
require_relative 'my_app'

#
# You can then run your app (don't forget you still need to be in a reviser workspace,
# so type/ and res/ folders must exist, as well as config.yml)
#
MyApp::run
```


Team
--------
[Anthony Cerf]()

[Yann Prono](https://github.com/mcdostone)

[Romain Ruez]()

[Renan Strauss](https://github.com/renan-)


Other stuff
-------------

|Question 	|   	Answer		 |
| ------------- | ------------------------------ |
| Requires      | Ruby 1.9.3 or later	 	 |