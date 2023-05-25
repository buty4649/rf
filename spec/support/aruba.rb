require 'aruba/rspec'

def run_rf(args, input = nil)
  rf_path = File.expand_path('../../build/bin/rf', __dir__)
  command = run_command("#{rf_path} #{args}")

  if input
    # chomp to remove unintended \n
    type input.chomp
    close_input
  end

  command
end
