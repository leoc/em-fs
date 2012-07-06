# -*- encoding: utf-8 -*-
require File.expand_path('../lib/em-fs/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Arthur Leonard Andersen"]
  gem.email         = ["leoc.git@gmail.com"]
  gem.description   = %q{`em-fs` provides libraries to access file system commands through an API similar to the Ruby file API for eventmachine.}
  gem.summary       = %q{Invoke filesystem calls without blocking.}
  gem.homepage      = "http://github.com/leoc/em-fs"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "em-fs"
  gem.require_paths = ["lib"]
  gem.version       = EventMachine::FS::VERSION

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-rspec'

  gem.add_dependency 'eventmachine'
  gem.add_dependency 'em-systemcommand'

end
