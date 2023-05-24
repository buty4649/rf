$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

Dir.glob(File.expand_path('support/*.rb', __dir__)).each { |f| require_relative f }
Dir.glob(File.expand_path('support/**/*.rb', __dir__)).each { |f| require_relative f }

RSpec.configure do |config|
  # need each parallel test to have its own working directory
  config.include Aruba::Api
  config.before { setup_aruba }
end
