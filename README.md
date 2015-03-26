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

Then you'll have to customize config.yml to your own needs. 

To perform the analysis, simply run:

	reviser work

###Configuration
---------------

This tool was thought to be very adaptable, thus it relies on YAML configuration files.

####Global configuration
Lives in *config.yml*.

|Key   |Description|Values|
|------|-----------|-----|
|*src*|Path to the archive containing projects||
|*dest*|Path to a directory where projects will be extracted||
|*projects_names*|Naming convention for projects|`^GROUP_NAME_NAME` `^GROUP_NAME(_NAME)*` `^TP_NAME_FIRSTN`|
|*out*|The name of the analysis output file||
|*out_format*|The formats that will be generated|`html` `xls` `csv`|
|*type*|The type of the project|`my_proj_type` (*type/my_project.yml* must exist)|
|*criteria*|The criteria you want for analysis|`all_files` `src_files` `lines_count` `comments_count` `compile` `execute`|
|*extensions*|The extensions (external criteria) you want for analysis|`memleaks` `validate_html` `validate_css` `validate_web`|
|*options*|A hash to set options|`:verbose` `:log_dir` `:log_mode`|

####Project configuration
Lives in *type/my_project.yml*.

|Key   |Description|Values|
|------|-----------|-----|
|*language*|The target language|`C` `Java` `HTML` `Ruby`|
|*required_files*|A list of required files|Tip: you can use regular expressions|
|*preferred_build_command*|The command to build the program with|`make`|
|*execute_command*|The name of the interpreter|`java` `ruby`|
|*program_prefix*|The program prefix|`pkg.` for Java|
|*program_name*|The name of the program|`a.out` `Main`|
|*execution_count*|The number of times to execute the program|default *1*|
|*execution_value*|The optional parameter to pass to the program when executing|A list of values whose length shall be one if *execution_count* is not greater than 1|
|*timeout*|In seconds. Compilation and execution will halt if not completed within the defined timeout||


Team
----
[Anthony Cerf]()

[Yann Prono](https://github.com/mcdostone)

[Romain Ruez]()

[Renan Strauss](https://github.com/renan-)


Other stuff
-------------

|Question 	|   	Answer		 |
| ------------- | ------------------------------ |
| Requires      | Ruby 1.9.3 or later	 	 |
