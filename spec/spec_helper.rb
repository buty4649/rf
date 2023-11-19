$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'rspec-parameterized'

Dir.glob(File.expand_path('support/*.rb', __dir__)).each { |f| require_relative f }
Dir.glob(File.expand_path('support/**/*.rb', __dir__)).each { |f| require_relative f }

def load_fixture(path)
  fixture = File.expand_path("fixtures/file/#{path}", __dir__)
  File.read(fixture)
end

RSpec.configure do |config|
  # need each parallel test to have its own working directory
  config.include Aruba::Api
  config.before { setup_aruba }

  Kernel.srand config.seed
end

def windows?
  /mswin(?!ce)|mingw|cygwin|bccwin/.match?(RUBY_PLATFORM)
end

def random_number(klass)
  number = rand(100)
  klass == Float ? number.to_f : number
end
