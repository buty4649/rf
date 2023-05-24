$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

Dir.glob(File.expand_path('support/*.rb', __dir__)).each { |f| require_relative f }
Dir.glob(File.expand_path('support/**/*.rb', __dir__)).each { |f| require_relative f }
