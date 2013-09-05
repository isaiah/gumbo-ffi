
# -*- encoding: utf-8 -*-
$:.push('lib')
require "gumbo_ffi/version"

Gem::Specification.new do |s|
  s.name     = "gumbo-ffi"
  s.version  = Gumbo::VERSION.dup
  s.date     = "2013-08-22"
  s.summary  = "Ruby binding for the gumbo html5 parser."
  s.email    = "issaria@gmail.com"
  s.homepage = "http://github.com/isaiah/gumbo-ffi"
  s.authors  = ['Isaiah Peng']
  
  s.description = <<-EOF
Gumbo is an implementation of the HTML5 parsing algorithm implemented as a pure C99 library with no outside dependencies. It's designed to serve as a building block for other tools and libraries such as linters, validators, templating languages, and refactoring and analysis tools.

This is the ruby binding library, via ffi.
EOF
  
  dependencies = [
      [:runtime, "ffi", "~> 1.9.0"]
    # Examples:
    # [:runtime,     "rack",  "~> 1.1"],
    # [:development, "rspec", "~> 2.1"],
  ]
  
  s.files         = Dir['**/*']
  s.test_files    = Dir['test/**/*']
  s.executables   = Dir['bin/*'].map { |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  
  ## Make sure you can build the gem on older versions of RubyGems too:
  s.rubygems_version = "1.8.23"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.specification_version = 3 if s.respond_to? :specification_version
  
  dependencies.each do |type, name, version|
    if s.respond_to?("add_#{type}_dependency")
      s.send("add_#{type}_dependency", name, version)
    else
      s.add_dependency(name, version)
    end
  end
end
