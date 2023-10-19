require 'aruba/rspec'

Aruba.configure do |config|
  # need custom working directory to avoia conflict with parallel tests
  working_directory = File.join('tmp/aruba', ENV['TEST_ENV_NUMBER'] || '1')
  config.working_directory = working_directory
  config.remove_ansi_escape_sequences = false
end

def rf_path
  %w[
    ../../build/host/bin/rf
    ../../build/build/bin/rf
    ../../build/build/bin/rf.exe
  ].map { |path| File.expand_path(path, __dir__) }
    .find { |path| File.exist?(path) }
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
