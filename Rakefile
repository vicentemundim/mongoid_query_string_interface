require "rake"
require "rake/rdoctask"
require "rspec"
require "rspec/core/rake_task"

require File.expand_path('lib/version.rb', File.dirname(__FILE__))

task :build do
  system "gem build mongoid_query_string_interface.gemspec"
end

task :install => :build do
  system "sudo gem install mongoid_query_string_interface-#{Mongoid::QueryStringInterface::VERSION}.gem"
end

task :release => :build do
  puts "Tagging #{Mongoid::QueryStringInterface::VERSION}..."
  system "git tag -a #{Mongoid::QueryStringInterface::VERSION} -m 'Bumping to version #{Mongoid::QueryStringInterface::VERSION}'"
  puts "Pushing to Github..."
  system "git push --tags"
  puts "Pushing to Rubygems..."
  system "gem push mongoid_query_string_interface-#{Mongoid::QueryStringInterface::VERSION}.gem"
end

Rspec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "Mongoid Query String Interface #{Mongoid::QueryStringInterface::VERSION}"
  rdoc.rdoc_files.include("README*")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

task :default => ["spec"]