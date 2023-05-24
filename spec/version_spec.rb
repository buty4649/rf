require_relative '../mrblib/rf/version'

describe 'Show version', type: :aruba do
  context 'long option' do
    before { run_rf('--version') }
    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output(Rf::VERSION) }
  end

  context 'short option' do
    before { run_rf('-v') }
    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output(Rf::VERSION) }
  end
end
