require_relative '../mrblib/rf/version'

describe 'Show version', type: :aruba do
  describe '--version' do
    before { run_rf('--version') }
    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stdout Rf::VERSION }
  end

  describe '-v' do
    before { run_rf('-v') }
    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stdout Rf::VERSION }
  end
end
