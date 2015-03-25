Gem::Specification.new do |spec|
  spec.name        = 'reviser'
  spec.version     = '0.0.2.rc1'
  spec.executables << 'reviser'
  spec.date        = '2015-03-25'
  spec.summary     = 'Reviser'
  spec.description = "A semi-automatic tool for student's projects evaluation"
  spec.authors     = ["Renan Strauss", "Yann Prono", "Anthony Cerf", "Romain Ruez"]
  spec.email       = 'renan.strauss@gmail.com'
  spec.files       = Dir['{bin,ext,lang,lib,res,type}/**/*'] + %w(Gemfile README.md config.yml labels.yml)
  spec.homepage    = 'http://rubygemspec.org/gems/reviser'
  spec.license     = 'GPL-3'

  spec.require_paths = ['lib', 'lib/helpers']

  spec.add_runtime_dependency 'colorize', '~> 0.7', '>= 0.7.5'
  spec.add_runtime_dependency 'thor', '~> 0.19', '>= 0.19.1'
  spec.add_runtime_dependency 'rubyzip', '~> 1.1', '>= 1.1.7'
  spec.add_runtime_dependency 'spreadsheet', '~> 1.0', '>= 1.0.3'
  spec.add_runtime_dependency 'git', '~> 1.2', '>= 1.2.9.1'
  spec.add_runtime_dependency 'rest-client', '~> 1.7', '>= 1.7.3'

  spec.add_runtime_dependency 'scrub_rb' unless RUBY_VERSION.split('.')[0] == '2'
end