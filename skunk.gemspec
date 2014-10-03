Gem::Specification.new do |gem|
  gem.authors       = ['Luis Doubrava', 'Rob van Aarle']
  gem.email         = ['luis@cg.nl', 'rob@cg.nl']
  gem.description   = 'Skunk'
  gem.summary       = 'Gem to monitor request lengths'
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'skunk'
  gem.require_paths = ['lib']
  gem.version       = "0.1.2"

  gem.add_dependency('rails', ['>= 3.0.0'])

  gem.add_development_dependency('rake', ['>= 0'])
  gem.add_development_dependency('rspec', ['>= 0'])
end