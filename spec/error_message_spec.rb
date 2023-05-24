describe 'Show error message', type: :aruba do
  context 'invalid option' do
    before { run_rf('--invalid-option') }
    let(:error_message) do
      'Error: invalid option: --invalid-option'
    end

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr error_message }
  end

  context 'invalid type' do
    before { run_rf('-t test') }
    let(:error_message) do
      'Error: "test" is invalid type. possible values: text,json,yaml'
    end

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr error_message }
  end

  context 'missing argument' do
    let(:error_message_prefix) do
      'Error: missing argument: '
    end

    %w[-t -F].each do |option|
      describe option do
        before { run_rf(option) }
        it { expect(last_command_started).not_to be_successfully_executed }
        it {
          error_message = "#{error_message_prefix}#{option}"
          expect(last_command_started).to have_output_on_stderr error_message
        }
      end
    end
  end
end
