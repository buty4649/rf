describe 'Show help text' do
  let(:help_text) do
    <<~TEXT
      Usage: rf [options] 'command' file ...
        -t, --type={text|json|yaml}      set the type of input (default:text)
        -j, --json                       equivalent to -tjson
        -y, --yaml                       equivalent to -tyaml
            --debug                      enable debug mode
        -n, --quiet                      suppress automatic priting
        -h, --help                       show this message
        -v, --version                    show version

      text options:
        -F, --filed-separator VAL        set the field separator(regexp)
    TEXT
  end

  describe '--help' do
    before { run_rf('--help') }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stdout output_string_eq help_text }
  end

  describe '-h' do
    before { run_rf('-h') }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stdout output_string_eq help_text }
  end

  context 'when empty option' do
    before { run_rf('') }

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr output_string_eq help_text }
  end

  context 'when not enough option' do
    before { run_rf('-t text') }

    it { expect(last_command_started).not_to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stderr output_string_eq help_text }
  end
end
