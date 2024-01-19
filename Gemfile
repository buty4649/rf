source 'https://rubygems.org/'

gem 'rake'

group 'test' do
  gem 'aruba', github: 'cucumber/aruba', branch: 'main'
  gem 'parallel_tests'
  gem 'rspec'
  gem 'rspec-parameterized', '>= 1.0.0'
  gem 'rubocop'
  gem 'rubocop-rspec'

  # fix: build error on windows
  gem 'ffi', github: 'ffi/ffi', branch: 'master'
end
