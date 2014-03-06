# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-guest_ansible/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-guest_ansible"
  spec.version       = Vagrant::GuestAnsible::VERSION
  spec.authors       = ["Roberto Quintanilla"]
  spec.email         = ["roberto.quintanilla@naranya.com"]
  spec.description   = %q{Ansible provisioner intended to run in the guest machine.}
  spec.summary       = %q{Ansible provisioner for guest machine.}
  spec.homepage      = "https://github.com/vovimayhem/vagrant-guest_ansible"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
