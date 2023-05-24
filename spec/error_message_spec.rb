describe 'Show error message', type: :aruba do
  context 'when invalid option' do
    before { run_rf('--invalid-option') }

    let(:error_message) do
      'Error: invalid option: --invalid-option'
    end

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr error_message }
  end

  context 'when invalid type' do
    before { run_rf('-t test') }

    let(:error_message) do
      'Error: "test" is invalid type. possible values: text,json,yaml'
    end

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr error_message }
  end

  context 'when missing argument' do
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

  context 'when syntax error' do
    let(:input) { "test\n" }
    let(:error_message) do
      'Error: line 1: syntax error, unexpected end of file'
    end

    before { run_rf('if', input) }

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr error_message }
  end

  context 'when no method error (StandardError)' do
    let(:input) { "test\n" }
    let(:error_message) do
      "Error: undefined method 'very_useful_method'"
    end

    before { run_rf('_.very_useful_method', input) }

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr error_message }
  end

  context 'when file not found' do
    let(:file) { 'not_found_file' }
    let(:error_message) do
      "Error: file not found: #{file}"
    end

    before { run_rf("'' #{file}") }

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr error_message }
  end

  context 'when enable debug mode' do
    let(:input) { "test\n" }
    let(:error_message) do
      <<~OUTPUT
        Error: line 1: syntax error, unexpected end of file (SyntaxError)

        trace (most recent call last):
      OUTPUT
    end

    before { run_rf('-d if', input) }

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr include_output_string error_message }
  end
end
