require File.expand_path('../lib/syrup/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'syrup_form_object'
  gem.version     = Syrup::VERSION
  gem.summary     = "Form Objects for ActiveRecord"
  gem.description = gem.summary
  gem.authors     = [ "Alex Siri" ]
  gem.email       = [ 'alexsiri7@gmail.com' ]
  gem.homepage    = 'https://github.com/alexsiri7/syrup_form_object'
  gem.license       = 'MIT'


  gem.require_paths    = [ "lib" ]
  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- {spec}/*`.split("\n")
  gem.extra_rdoc_files = %w[LICENSE README.md]

  gem.add_dependency('virtus', '~> 1.0.0')
end
