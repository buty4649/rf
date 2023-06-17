describe 'Show help text' do
  let(:help_text) do
    <<~TEXT
      Usage: rf [options] 'command' file ...
             rf [options] -f program_file file ...
      global options:
        -t, --type={text|json|yaml}      set the type of input (default: text)
        -j, --json                       same as -tjson
        -y, --yaml                       same as -tyaml
        -A, --read-all                   read all reacords at once
        -f, --file=program_file          executed the contents of program_file
        -n, --quiet                      suppress automatic priting
            --debug                      enable debug mode
            --help                       show this message
            --version                    show version

      text options:
        -F, --filed-separator VAL        set the field separator(regexp)

      json options:
        -r, --raw-string                 output raw strings

      yaml options:
            --[no-]doc                   [no] output document sperator(---) (default:--no-doc)
    TEXT
  end

  describe '--help' do
    before { run_rf('--help') }

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
