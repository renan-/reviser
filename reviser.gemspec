Gem::Specification.new do |s|
  s.name        = 'reviser'
  s.version     = '0.0.1'
  s.executables << 'reviser'
  s.date        = '2015-03-16'
  s.summary     = "Reviser"
  s.description = "A semi-automatic tool for student's projects evaluation"
  s.authors     = ["Renan Strauss", "Yann Prono", "Anthony Cerf", "Romain Ruez"]
  s.email       = 'renan.strauss@gmail.com'
  s.files       =
  [
    # Sources
    'lib/component.rb', 'lib/config.rb', 'lib/exec.rb', 'lib/project.rb', 'lib/reviser.rb',
    'lib/loggers/logger.rb', 'lib/loggers/modes.rb',
    'lib/helpers/code_analysis.rb', 'lib/helpers/compilation.rb', 'lib/helpers/criteria.rb', 'lib/helpers/execution.rb', 'lib/helpers/git.rb', 'lib/helpers/utils.rb',
    'lib/components/archiver.rb', 'lib/components/checker.rb', 'lib/components/extractors.rb', 'lib/components/generator.rb', 'lib/components/generators.rb', 'lib/components/organiser.rb',
    'ext/html_validator.rb', 'ext/valgrind.rb',
    # Config files
    'config.yml', 'labels.yml',
    'lang/C.yml', 'lang/HTML.yml', 'lang/Java.yml', 'lang/Ruby.yml',
    'type/Labyrinthe.yml', 'type/HtmlASRALL.yml', 'type/CProject.yml', 'type/HelloWorldRuby.yml',
    # Resources
    'res/css/component.css', 'res/css/normalize.css',
    'res/js/jquery.stickyheader.js'
  ]
  s.homepage    = 'http://rubygems.org/gems/reviser'
  s.license     = 'MIT'
end