describe 'Show error message' do
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

  context 'when file is directory' do
    let(:file) { '.' }
    let(:error_message) do
      "Error: #{file}: is a directory"
    end

    before { run_rf("_ #{file}") }

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr error_message }
  end

  context 'when permission denied' do
    let(:file) { 'testfile' }
    let(:error_message) do
      "Error: #{file}: permission denied"
    end

    before do
      touch(file)
      if windows?
        # drop all permissions
        `icacls #{file} /inheritancelevel:r`
      else
        chmod(0o000, file)
      end
      run_rf("_ #{file}")

      # restore permissions
      `icalcs #{file} /inheritancelevel:e` if windows?
    end

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr error_message }
  end

  context 'when enable debug mode' do
    let(:input) { "test\n" }
    let(:error_message) do
      <<~OUTPUT
        Error: line 1: syntax error, unexpected end of file (Rf::SyntaxError)

        trace (most recent call last):
      OUTPUT
    end

    before do
      ENV['RF_DEBUG'] = 'y'
      run_rf('if', input)
      ENV['RF_DEBUG'] = nil
    end

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr include_output_string error_message }
  end

  context 'when method missing' do
    describe 'internal method' do
      let(:input) { "test\n" }
      let(:error_message) { "Error: undefined method 'unknown_method'" }

      before { run_rf('unknown_method', input) }

      it { expect(last_command_started).not_to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stderr include_output_string error_message }
    end

    describe 'Hash method' do
      let(:input) { load_fixture('json/hash.json') }
      let(:error_message) { "Error: undefined method 'unknown_method'" }

      before { run_rf('_.unknown_method', input) }

      it { expect(last_command_started).not_to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stderr include_output_string error_message }
    end
  end

  context 'when program file not found' do
    let(:input) { "test\n" }
    let(:error_message) { 'Error: No such file or directory - open program_file' }

    before { run_rf('-f program_file', input) }

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr include_output_string error_message }
  end
end
