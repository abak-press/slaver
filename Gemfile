source 'https://rubygems.org'

gemspec

group :test do
  if RUBY_VERSION < '2'
    gem 'mime-types', '< 3.0'
    gem 'json', '< 2.0'
    gem 'nokogiri', '< 1.7.0'
  else
    gem 'test-unit'
    gem 'pry-byebug'
  end
end
