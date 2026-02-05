require 'aruba/rspec'

Aruba.configure do |config|
  # need custom working directory to avoia conflict with parallel tests
  working_directory = File.join('tmp/aruba', ENV['TEST_ENV_NUMBER'] || '1')
  config.working_directory = working_directory
  config.remove_ansi_escape_sequences = false
  config.exit_timeout = 3
end

def rf_path
  %w[
    ../../build/host/bin/rf
    ../../build/bin/rf
    ../../build/bin/rf.exe
  ].map { |path| File.expand_path(path, __dir__) }
   .find { |path| File.exist?(path) }
end

def run_rf(args, input = nil)
  @rf_path ||= rf_path
  a = args.is_a?(Array) ? args.join(' ') : args
  command = run_command("#{rf_path} #{a}")

  if input
    # chomp to remove unintended \n
    type input.chomp
    close_input
  end

  # Call the stop method here to avoid IO waiting on command output.
  # This approach efficiently handles the output processing by caching it immediately,
  # preventing any potential delays due to IO operations.
  command.stop

  command
end

def read_file(path)
  File.read(expand_path(path))
end
