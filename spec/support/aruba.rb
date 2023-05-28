require 'aruba/rspec'

Aruba.configure do |config|
  # need custom working directory to avoia conflict with parallel tests
  working_directory = File.join('tmp/aruba', ENV['TEST_ENV_NUMBER'] || '1')
  config.working_directory = working_directory
end

def rf_path
  rf_path = File.expand_path('../../build/bin/rf', __dir__)
  return rf_path if File.exist?(rf_path)

  "#{rf_path}.exe"
end

def run_rf(args, input = nil)
  @rf_path ||= rf_path
  command = run_command("#{rf_path} #{args}")

  if input
    # chomp to remove unintended \n
    type input.chomp
    close_input
  end

  command
end
