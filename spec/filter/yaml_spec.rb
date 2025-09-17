describe 'YAML filter' do
  context 'with -t option' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { 'test' }

      before { run_rf('yaml _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'with -r option' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/multibyte_string.yml') }
      let(:args) { 'yaml -r _' }
      let(:expect_output) { "🍣🍣🍣\n" }

      it_behaves_like 'a successful exec'
    end

    describe 'Ouput yaml to JSON string' do
      let(:input) { load_fixture('json/hash.json') }
      let(:args) { 'yaml -r "_.to_json(pretty_print: true)"' }
      let(:expect_output) do
        <<~OUTPUT
          {
            "foo": 1,
            "bar": {
              "baz": [
                "a",
                "b",
                "c"
              ]
            },
            "foo bar": "foo bar"
          }
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'with -R option' do
    let(:output) do
      <<~OUTPUT
        bar
        foobarbaz
        foo
      OUTPUT
    end

    before do
      write_file('bar.yaml', 'bar')
      write_file('foo.yml', 'foo')
      write_file('notmatch.txt', 'not match')
      write_file('notmatch.json', '"not match"')
      FileUtils.mkdir_p(expand_path('a/b'))
      write_file('foo/bar/baz.yml', 'foobarbaz')
      write_file('foo/bar/notmatch.txt', 'not match')
      write_file('foo/bar/notmatch.json', '"not match"')

      run_rf('yaml -R _ .')
    end

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end

  context 'with -g option' do
   let(:input) { 'foo' }
   let(:output) { 'foo' }

   where(:command) do
     %w[-g --grep]
   end

   with_them do
     before { run_rf("yaml #{command} .", input) }

     it { expect(last_command_started).to be_successfully_executed }
     it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
   end
  end

  context 'when input from stdin' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { 'test' }

      before { run_rf('yaml _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Output UTF-8 string' do
      let(:input) { 'あいうえお🍣' }
      let(:args) { 'yaml _' }
      let(:expect_output) { "あいうえお🍣\n" }

      it_behaves_like 'a successful exec'
    end

    describe 'Output each object of the array one by one' do
      let(:input) { load_fixture('yaml/array.yml') }
      let(:output) do
        <<~OUTPUT
          foo
          bar
          baz
        OUTPUT
      end

      before { run_rf('yaml _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Output only the filtered objects' do
      let(:input) { load_fixture('yaml/array.yml') }
      let(:output) { 'foo' }

      before { run_rf('yaml /foo/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Output the value of the selected Hash key' do
      let(:input) { load_fixture('yaml/hash.yml') }
      let(:output) do
        <<~OUTPUT
          - a
          - b
          - c
        OUTPUT
      end

      before { run_rf('yaml "_.bar.baz"', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Output the value of the selected Hash space included key' do
      let(:input) { load_fixture('yaml/hash.yml') }
      let(:output) { 'foo bar' }

      before { run_rf(%q(yaml '_["foo bar"]'), input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Read all at once' do
      let(:input) { load_fixture('yaml/hash.yml') }
      let(:output) do
        '[{"foo" => 1, "bar" => {"baz" => ["a", "b", "c"]}, "foo bar" => "foo bar"}]'
      end

      before { run_rf("yaml -s -q 'p _'", input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when input from file' do
    describe 'Output string' do
      let(:file) { 'test.yml' }
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { 'test' }

      before do
        write_file file, input
        run_rf("yaml _ #{file}")
      end

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when suppress automatic printing' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { '' }

      before { run_rf('yaml -q _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when use regexp' do
    describe 'Input as String' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { 'test' }

      before { run_rf('yaml /test/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Input as Number' do
      let(:input) { load_fixture('yaml/number.yml') }
      let(:output) { '123456789' }

      before { run_rf('yaml /123456789/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Input as Hash' do
      let(:input) { 'foo: bar' }
      let(:output) { input }

      before { run_rf('yaml /foo/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'with --doc option' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { '--- test' }

      before { run_rf('yaml --doc _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Output hash' do
      let(:input) { load_fixture('yaml/hash.yml') }
      let(:args) { 'yaml --doc _' }
      let(:expect_output) do
        <<~OUTPUT
          ---
          foo: 1
          bar:
            baz:
              - a
              - b
              - c
          foo bar: foo bar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'with --disable-boolean-mode option' do
    let(:input) { 'foobar' }

    where do
      {
        'TrueClass' => {
          command: 'true',
          expect_output: "true\n"
        },
        'FalseClass' => {
          command: 'false',
          expect_output: "false\n"
        },
        'NilClass' => {
          command: 'nil',
          expect_output: "null\n"
        },
        'Hash with null value' => {
          command: '{foo: nil}',
          expect_output: ":foo: null\n"
        }
      }
    end

    with_them do
      let(:args) { "yaml --disable-boolean-mode '#{command}'" }

      it_behaves_like 'a successful exec'
    end
  end

  context 'when use -H option' do
    let(:input) { 'foobar' }
    let(:args) { 'yaml -H --no-color true testfile' }
    let(:expect_output) do
      out = input.split("\n").map { |line| "testfile:#{line}" }.join("\n")
      "#{out}\n"
    end

    before do
      write_file 'testfile', input
    end

    it_behaves_like 'a successful exec'
  end

  context 'when multiple files' do
    let(:input) { 'foobar' }

    where do
      {
        'without -H option' => {
          option: '',
          expect_output: <<~OUTPUT
            foobar
            foobar
          OUTPUT
        },
        'with -H option' => {
          option: '-H',
          expect_output: <<~OUTPUT
            testfile1:foobar
            testfile2:foobar
          OUTPUT
        }
      }
    end

    with_them do
      let(:args) { "yaml #{option} --no-color true testfile1 testfile2" }
      before do
        write_file 'testfile1', input
        write_file 'testfile2', input
      end

      it_behaves_like 'a successful exec'
    end
  end

  describe 'Output nil value' do
    let(:input) { 'foobar' }
    let(:output) { '' }

    before { run_rf('yaml nil', input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end
end
