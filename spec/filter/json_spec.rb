describe 'JSON filter' do
  context 'with -t option' do
    describe 'Output string' do
      let(:input) { load_fixture('json/string.json') }
      let(:args) { 'json _' }
      let(:expect_output) { "\"test\"\n" }

      it_behaves_like 'a successful exec'
    end
  end

  context 'with -r option' do
    describe 'Output string' do
      let(:input) { load_fixture('json/string.json') }
      let(:args) { 'json -r _' }
      let(:expect_output) { "test\n" }

      it_behaves_like 'a successful exec'
    end

    # When using pipes, `--no-color` is implicitly applied internally, so we explicitly test for it.
    context 'with --color option' do
      let(:input) { load_fixture('json/string.json') }
      let(:args) { 'json -r --color _' }
      let(:expect_output) { "test\n" }

      it_behaves_like 'a successful exec'
    end
  end

  context 'with --disable-boolean-mode option' do
    let(:input) { '"foobar"' }

    where do
      {
        'TrueClass' => {
          command: 'true',
          output: 'true'
        },
        'FalseClass' => {
          command: 'false',
          output: 'false'
        },
        'NilClass' => {
          command: 'nil',
          output: 'null'
        }
      }
    end

    with_them do
      before { run_rf("json --disable-boolean-mode '#{command}'", input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when use -H option' do
    let(:input) { '"foobar"' }
    let(:args) { 'json -H --no-color true testfile' }
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
    let(:args) { 'json -R _ .' }
    let(:expect_output) do
      <<~OUTPUT
        "foobarbaz"
        "foo"
      OUTPUT
    end

    before do
      write_file('foo.json', '"foo"')
      write_file('notmatch.txt', '"not match"')
      write_file('notmatch.yml', '"not match"')
      FileUtils.mkdir_p(expand_path('a/b'))
      write_file('foo/bar/baz.json', '"foobarbaz"')
      write_file('foo/bar/notmatch.txt', '"not match"')
      write_file('foo/bar/notmatch.yml', '"not match"')
    end

    it_behaves_like 'a successful exec'
  end

  context 'with -g option' do
    let(:input) { '"foo"' }
    let(:output) { '"foo"' }

    where(:command) do
      %w[-g --grep]
    end

    with_them do
      before { run_rf("json #{command} .", input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end

  context 'when multiple files' do
    let(:input) { '"foobar"' }

    where do
      {
        'without -H option' => {
          option: '',
          expect_output: <<~OUTPUT
            "foobar"
            "foobar"
          OUTPUT
        },
        'with -H option' => {
          option: '-H',
          expect_output: <<~OUTPUT
            testfile1:"foobar"
            testfile2:"foobar"
          OUTPUT
        }
      }
    end

    with_them do
      let(:args) { "json #{option} --no-color true testfile1 testfile2" }
      before do
        write_file 'testfile1', input
        write_file 'testfile2', input
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'when input from stdin' do
    describe 'Output string' do
      let(:input) { load_fixture('json/string.json') }
      let(:args) { 'json _' }
      let(:expect_output) { "\"test\"\n" }

      it_behaves_like 'a successful exec'
    end

    describe 'Output each object of the array one by one' do
      let(:input) { load_fixture('json/array.json') }
      let(:args) { 'json _' }
      let(:expect_output) do
        <<~OUTPUT
          "foo"
          "bar"
          "baz"
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    describe 'Output only the filtered objects' do
      let(:input) { load_fixture('json/array.json') }
      let(:args) { 'json /foo/' }
      let(:expect_output) { "\"foo\"\n" }

      it_behaves_like 'a successful exec'
    end

    describe 'Output the value of the selected Hash key' do
      let(:input) { load_fixture('json/hash.json') }
      let(:args) { 'json "_.bar.baz"' }
      let(:expect_output) do
        <<~OUTPUT
          [
            "a",
            "b",
            "c"
          ]
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    describe 'Output the value of the selected Hash space included key' do
      let(:input) { load_fixture('json/hash.json') }
      let(:args) { %q(json '_["foo bar"]') }
      let(:expect_output) { "\"foo bar\"\n" }

      it_behaves_like 'a successful exec'
    end

    describe 'Read all at once' do
      let(:input) { load_fixture('json/hash.json') }
      let(:args) { "json -s -q 'p _'" }
      let(:expect_output) do
        "[{\"foo\" => 1, \"bar\" => {\"baz\" => [\"a\", \"b\", \"c\"]}, \"foo bar\" => \"foo bar\"}]\n"
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'when input from file' do
    describe 'Output string' do
      let(:file) { 'test.json' }
      let(:input) { load_fixture('json/string.json') }
      let(:args) { "json _ #{file}" }
      let(:expect_output) { "\"test\"\n" }

      before do
        write_file file, input
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'when suppress automatic printing' do
    describe 'Output string' do
      let(:input) { load_fixture('json/string.json') }
      let(:args) { 'json -q _' }
      let(:expect_output) { '' }

      it_behaves_like 'a successful exec'
    end
  end

  context 'when use regexp' do
    describe 'Input as String' do
      let(:input) { load_fixture('json/string.json') }
      let(:args) { 'json /test/' }
      let(:expect_output) { "\"test\"\n" }

      it_behaves_like 'a successful exec'
    end

    describe 'Input as Number' do
      let(:input) { load_fixture('json/number.json') }
      let(:args) { 'json /123456789/' }
      let(:expect_output) { "123456789\n" }

      it_behaves_like 'a successful exec'
    end

    describe 'Input as Hash' do
      let(:input) { '{"foo": "bar"}' }
      let(:args) { 'json /foo/' }
      let(:expect_output) do
        <<~OUTPUT
          {
            "foo": "bar"
          }
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'when inptut is invalid JSON' do
    describe 'Error message' do
      let(:input) { '{"foo": "bar"' }

      let(:args) { 'json _' }
      let(:expect_output) do
        "Error: failed to parse JSON: unexpected end of data position: 14\n"
      end

      it_behaves_like 'a failed exec'
    end
  end

  context 'with duplicate keys in the input object' do
    describe 'Output string' do
      let(:input) { '{"foo": "bar", "foo": "baz"}' }

      let(:args) { 'json _' }
      let(:expect_output) do
        <<~JSON
          {
            "foo": "baz"
          }
        JSON
      end

      it_behaves_like 'a successful exec'
    end
  end
end
