# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'port_map/version'

Gem::Specification.new do |spec|
  spec.name          = 'port_map'
  spec.version       = PortMap::VERSION
  spec.authors       = ['Kevin Jalbert']
  spec.email         = ['kevin.j.jalbert@gmail.com']

  spec.summary       = 'Provides an easy and mostly automatic way of mapping ports to local domains'
  spec.description   = 'Provides an easy and mostly automatic way of mapping ports to local domains'
  spec.homepage      = 'https://github.com/kevinjalbert/port_map/'
  spec.license       = 'MIT'

  spec.files         = Dir['**/*']
  spec.test_files    = Dir['{test,spec,features}/**/*']
  spec.executables   = Dir['bin/*'].map { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4.0'
  spec.add_development_dependency 'pry', '~> 0.10.0'
end
