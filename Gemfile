source 'http://rubygems.org'

gemspec

gem "rake", "0.8.7"
gem 'bson'
gem 'bson_ext'

platforms :mri_18 do
  gem "ruby-debug"
end

platforms :mri_19 do
  gem "ruby-debug19", :require => 'ruby-debug' if RUBY_VERSION < "1.9.3"
end
