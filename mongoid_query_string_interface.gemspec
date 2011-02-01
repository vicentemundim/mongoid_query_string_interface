# -*- encoding: utf-8 -*-
require File.expand_path('lib/version.rb', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name = "mongoid_query_string_interface"
  s.version = Mongoid::QueryStringInterface::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Vicente Mundim"]
  s.email = ["vicente.mundim@gmail.com"]
  s.homepage = "http://github.com/vicentemundim/mongoid_query_string_interface"
  s.summary = "An interface for performing queries in MongoDB using query string parameters."
  s.description = "Gives a method that can parse query string parameters into a set of criterias that Mongoid can use to perform actual queries in MongoDB databases for a given model."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = "mongoid_query_string_interface"

  s.add_runtime_dependency("json", [">= 1.4.6"])
  s.add_runtime_dependency("mongoid", ["~> 2.0.0.rc"])

  s.add_development_dependency(%q<rspec>, [">= 2.3.0"])
  s.add_development_dependency(%q<database_cleaner>, [">= 0.5.0"])

  s.files = Dir.glob("lib/**/*") + %w(MIT_LICENSE README.rdoc Gemfile Gemfile.lock)
  s.require_path = 'lib'
end

