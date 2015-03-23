Gem::Specification.new do |s|
  s.name        = 'reviser'
  s.version     = '0.0.2-beta'
  s.executables << 'reviser'
  s.date        = '2015-03-23'
  s.summary     = 'Reviser'
  s.description = "A semi-automatic tool for student's projects evaluation"
  s.authors     = ["Renan Strauss", "Yann Prono", "Anthony Cerf", "Romain Ruez"]
  s.email       = 'renan.strauss@gmail.com'
  s.files       = Dir['{bin,ext,lang,lib,res,type}/**/*'] + %w(Gemfile README.md config.yml labels.yml)
  s.homepage    = 'http://rubygems.org/gems/reviser'
  s.license     = 'MIT'
end