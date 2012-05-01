# -*- encoding: utf-8 -*-
require File.expand_path('../lib/jumpstart/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Brian Hempel"]
  gem.email         = ["plastichicken@gmail.com"]
  gem.description   = "Pseudo-shell hack with Rails environment preloaded for faster boot times and thus faster testing iterations."
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/brianhempel/jumpstart"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "jumpstart"
  gem.require_paths = ["lib"]
  gem.version       = Jumpstart::VERSION
end
