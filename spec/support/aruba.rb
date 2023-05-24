require 'aruba/rspec'

def run_rf(args)
  rf_path = File.expand_path('../../build/bin/rf', __dir__)
  run_command("#{rf_path} #{args}")
end
