describe 'Show help text' do
  let(:expect_output) do
    <<~TEXT
      Usage: rf [filter type] [options] 'command' file ...
             rf [filter type] [options] -f program_file file ...
      filter types:
        -t, --type={text|json|yaml}      set the type of input (default: text)
        -j, --json                       same as --type=json
        -y, --yaml                       same as --type=yaml

      global options:
        -H, --with-filename              print filename with output lines
            --with-record-number         print record number with output lines
        -R, --recursive                  read all files under each directory recursively
            --include-filename           searches for files matching a regex pattern
        -f, --file=program_file          executed the contents of program_file
        -g, --grep                       Interpret command as a regex pattern for searching (like grep)
        -i, --in-place[=SUFFIX]          edit files in place (makes backup if SUFFIX supplied)
        -n, --quiet                      suppress automatic printing
        -s, --slurp                      read all reacords into an array
            --[no-]color                 [no] colorized output (default: --color in TTY)
            --help                       show this message
            --version                    show version

      text options:
        -F, --filed-separator VAL        set the field separator (allow regexp)

      json options:
        -r, --raw-string                 output raw strings
            --disable-boolean-mode       consider true/false/null as json literal
        -m, --minify                     minify json output

      yaml options:
            --disable-boolean-mode       consider true/false/null as yaml literal
            --[no-]doc                   [no] output document sperator (refers to ---) (default:--no-doc)
    TEXT
  end

  where(:args) do
    %w[--help -h]
  end

  with_them do
    it_behaves_like 'a successful exec'
  end

  where(:args) do
    ['', '-t text']
  end

  with_them do
    it_behaves_like 'a failed exec'
  end
end
