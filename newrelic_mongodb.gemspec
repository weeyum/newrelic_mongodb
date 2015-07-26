# -*- encoding: utf-8 -*-
require File.expand_path('../lib/newrelic_mongodb/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["William Li"]
  gem.email         = ["weeyum@gmail.com"]
  gem.description   = %q{New Relic instrumentation for Mongo Ruby Driver(2.x) / Mongoid (5.x)}
  gem.summary       = %q{New Relic instrumentation for Mongo Ruby Driver(2.x) / Mongoid (5.x)}
  gem.homepage      = "https://github.com/weeyum/newrelic_mongodb"
  gem.license       = "MIT"
  gem.files         = Dir["{lib}/**/*.rb", "LICENSE", "*.md"]
  gem.name          = "newrelic_mongodb"
  gem.require_paths = ["lib"]
  gem.version       = NewrelicMongodb::VERSION

  gem.add_dependency 'newrelic_rpm', '~> 3.11'
  gem.add_dependency 'mongo', '>= 2.1.0.beta', '< 3'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'test-unit'
end
