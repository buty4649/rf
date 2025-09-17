describe 'Text filter' do
  let(:input) do
    <<~INPUT
      1 foo
      2 bar
      3 baz
      4 foobar
    INPUT
  end

  context 'when use -t option' do
    describe 'Output all lines' do
      let(:output) { input }

      before { run_rf('text true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end

  context 'when use -f option' do
    describe 'Output all lines' do
      let(:output) { input }

      before do
        write_file 'program.rf', 'true'
        run_rf('text -f program.rf', input)
      end

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
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
      let(:output) { input }

      before { run_rf('text true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end

    describe 'Output only the second filed' do
      let(:output) do
        <<~OUTPUT
          foo
          bar
          baz
          foobar
        OUTPUT
      end

      before { run_rf('text _2', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
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
      let(:output) do
        <<~OUTPUT
          foo
          foo
        OUTPUT
      end

      before { run_rf('text _.match(/foo/)', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end

    describe 'Output the sum of all the values in the first column' do
      let(:output) do
        <<~OUTPUT
          10
        OUTPUT
      end

      before { run_rf('text -q "s||=0; s+=_1; at_exit{ puts s }"', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end

    describe 'Output the uppercase letters' do
      let(:output) do
        <<~OUTPUT
          1 FOO
          2 BAR
          3 BAZ
          4 FOOBAR
        OUTPUT
      end

      before { run_rf('text _.upcase', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end

    describe 'Read all at once' do
      let(:output) { '1 foo 2 bar 3 baz 4 foobar' }

      before { run_rf('text -s "_"', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end

  context 'when input from file' do
    describe 'Output all lines' do
      let(:file) { 'test.txt' }
      let(:output) { input }

      before do
        write_file file, input
        run_rf("text true #{file}")
      end

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end

  context 'when suppress automatic printing' do
    describe 'Output all lines' do
      let(:output) { '' }

      before { run_rf('text -q true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
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
      let(:output) do
        <<~OUTPUT
          foo
          bar
          baz
          foobar
        OUTPUT
      end

      before { run_rf('text -F, _2', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end

  describe 'Output the array is automatically joined with the spaces' do
    let(:input) { 'foo,bar,baz' }
    let(:output) { 'foo bar baz' }

    before { run_rf('text -F, $F', input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
  end
end
