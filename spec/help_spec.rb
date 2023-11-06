describe 'Show help text' do
  let(:help_text) do
    <<~TEXT
      Usage: rf [filter type] [options] 'command' file ...
             rf [filter type] [options] -f program_file file ...
      filter types:
        -t, --type={text|json|yaml}      set the type of input (default: text)
        -j, --json                       same as --type=json
        -y, --yaml                       same as --type=yaml

      global options:
        -H, --with-filename              print filename with output lines
        -R, --recursive                  read all files under each directory recursively
            --include-filename           searches for files matching a regex pattern
        -f, --file=program_file          executed the contents of program_file
        -g, --grep                       Interpret command as a regex pattern for searching (like grep)
        -n, --quiet                      suppress automatic printing
        -s, --slurp                      read all reacords into an array
            --help                       show this message
            --version                    show version

      text options:
        -F, --filed-separator VAL        set the field separator (allow regexp)
            --[no-]color                 [no] colorized output (default: --color)

      json options:
        -r, --raw-string                 output raw strings
            --disable-boolean-mode       consider true/false/null as json literal

      yaml options:
        -r, --raw-string                 output raw strings
            --disable-boolean-mode       consider true/false/null as yaml literal
            --[no-]doc                   [no] output document sperator (refers to ---) (default:--no-doc)
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
