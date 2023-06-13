require_relative '../mrblib/rf/version'

describe 'Show version', type: :aruba do
  let(:output) do
    /^rf #{Rf::VERSION} \(mruby \d\.\d\.\d\)$/
  end

  describe '--version' do
    before { run_rf('--version') }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stdout output }
  end

  describe '-v' do
    before { run_rf('-v') }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stdout output }
  end
end
