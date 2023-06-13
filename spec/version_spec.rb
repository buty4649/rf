require_relative '../mrblib/rf/version'

describe 'Show version', type: :aruba do
  describe '--version' do
    let(:output) do
      /^rf #{Rf::VERSION} \(mruby \d\.\d\.\d\)$/
    end

    before { run_rf('--version') }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stdout output }
  end
end
