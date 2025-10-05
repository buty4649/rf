describe 'Text filter' do
  let(:input) { load_fixture('text/test.txt') }

  context 'when text command is default (no explicit command)' do
    describe 'Output all lines' do
      let(:args) { 'true' }
      let(:expect_output) { input }

      it_behaves_like 'a successful exec'
    end

    describe 'Output only the second field' do
      let(:args) { '_2' }
      let(:expect_output) do
        <<~OUTPUT
          foo
          bar
          baz
          foobar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    describe 'Use field separator option without text command' do
      let(:input) do
        <<~INPUT
          1,foo
          2,bar
          3,baz
          4,foobar
        INPUT
      end
      let(:args) { '-F, _2' }
      let(:expect_output) do
        <<~OUTPUT
          foo
          bar
          baz
          foobar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    describe 'Use grep option without text command' do
      let(:args) { '-g --no-color foo' }
      let(:expect_output) do
        <<~OUTPUT
          1 foo
          4 foobar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    describe 'Use quiet option without text command' do
      let(:args) { '-q "s||=0; s+=_1; at_exit{ puts s }"' }
      let(:expect_output) do
        <<~OUTPUT
          10
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'when use -t option' do
    describe 'Output all lines' do
      let(:args) { 'text true' }
      let(:expect_output) { input }

      it_behaves_like 'a successful exec'
    end
  end

  context 'when use -f option' do
    describe 'Output all lines' do
      let(:args) { 'text -f program.rf' }
      let(:expect_output) { input }

      before do
        write_file 'program.rf', 'true'
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'when use -H option' do
    let(:args) { 'text -H --no-color true testfile' }
    let(:expect_output) do
      out = input.split("\n").map { |line| "testfile:#{line}" }.join("\n")
      "#{out}\n"
    end

    before do
      write_file 'testfile', input
    end

    it_behaves_like 'a successful exec'
  end

  context 'with -R option' do
    let(:args) { 'text -R --no-color _ .' }
    let(:expect_output) do
      <<~OUTPUT
        ./a/b/c:abc
        ./foo/bar:foobar
      OUTPUT
    end

    before do
      FileUtils.mkdir_p(expand_path('a/b'))
      write_file('a/b/c', 'abc')
      FileUtils.mkdir_p(expand_path('foo'))
      write_file('foo/bar', 'foobar')
    end

    it_behaves_like 'a successful exec'
  end

  context 'with -g option' do
    let(:input) { 'foo' }
    let(:output) { "\e[31mf\e[m\e[31mo\e[m\e[31mo\e[m" }

    where(:command) do
      %w[-g --grep]
    end

    with_them do
      before { run_rf("text #{command} --color .", input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end

  context 'when multiple files' do
    let(:args) { 'text --no-color true testfile1 testfile2' }
    let(:expect_output) do
      out = [
        input.split("\n").map { |line| "testfile1:#{line}" }.join("\n"),
        input.split("\n").map { |line| "testfile2:#{line}" }.join("\n")
      ].join("\n")
      "#{out}\n"
    end

    before do
      write_file 'testfile1', input
      write_file 'testfile2', input
    end

    it_behaves_like 'a successful exec'
  end

  context 'when input from stdin' do
    describe 'Output all lines' do
      let(:args) { 'text true' }
      let(:expect_output) { input }

      it_behaves_like 'a successful exec'
    end

    describe 'Output only the second filed' do
      let(:args) { 'text _2' }
      let(:expect_output) do
        <<~OUTPUT
          foo
          bar
          baz
          foobar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    describe 'Output only the lines that match the regexp' do
      where do
        {
          'default' => {
            option: '',
            output: <<~OUTPUT
              1 foo
              4 foobar
            OUTPUT
          },
          '--color' => {
            option: '--color',
            output: <<~OUTPUT
              1 \e[31mfoo\e[m
              4 \e[31mfoo\e[mbar
            OUTPUT
          },
          '--no-color' => {
            option: '--no-color',
            output: <<~OUTPUT
              1 foo
              4 foobar
            OUTPUT
          }
        }
      end
      with_them do
        before { run_rf("text #{option} /foo/", input) }

        it { expect(last_command_started).to be_successfully_executed }
        it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
      end
    end

    describe 'Output only the substring that matches the regexp' do
      let(:args) { 'text _.match(/foo/)' }
      let(:expect_output) do
        <<~OUTPUT
          foo
          foo
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    describe 'Output the sum of all the values in the first column' do
      let(:args) { 'text -q "s||=0; s+=_1; at_exit{ puts s }"' }
      let(:expect_output) do
        <<~OUTPUT
          10
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    describe 'Output the uppercase letters' do
      let(:args) { 'text _.upcase' }
      let(:expect_output) do
        <<~OUTPUT
          1 FOO
          2 BAR
          3 BAZ
          4 FOOBAR
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    describe 'Read all at once' do
      let(:args) { 'text -s "_"' }
      let(:expect_output) { "1 foo 2 bar 3 baz 4 foobar\n" }

      it_behaves_like 'a successful exec'
    end
  end

  context 'when input from file' do
    describe 'Output all lines' do
      let(:file) { 'test.txt' }
      let(:args) { "text true #{file}" }
      let(:expect_output) { input }

      before do
        write_file file, input
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'when suppress automatic printing' do
    describe 'Output all lines' do
      let(:args) { 'text -q true' }
      let(:expect_output) { '' }

      it_behaves_like 'a successful exec'
    end
  end

  context 'when change the field separator' do
    describe 'Output only the second filed' do
      let(:input) do
        <<~INPUT
          1,foo
          2,bar
          3,baz
          4,foobar
        INPUT
      end
      let(:args) { 'text -F, _2' }
      let(:expect_output) do
        <<~OUTPUT
          foo
          bar
          baz
          foobar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end

  describe 'Output the array is automatically joined with the spaces' do
    let(:input) { 'foo,bar,baz' }
    let(:args) { 'text -F, $F' }
    let(:expect_output) { "foo bar baz\n" }

    it_behaves_like 'a successful exec'
  end
end
