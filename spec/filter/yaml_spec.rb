describe 'YAML filter' do
  context 'with -t option' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:args) { 'yaml _' }
      let(:expect_output) { "test\n" }

      it_behaves_like 'a successful exec'
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
      let(:input) { load_fixture('yaml/hash.yml') }
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

      where(:args) do
        [
          'yaml -r "_.to_json"',
          'yaml -r "_.to_json"'
        ]
      end

      with_them do
        it_behaves_like 'a successful exec'
      end
    end
  end

  context 'with -R option' do
    let(:args) { 'yaml -R _ .' }
    let(:expect_output) do
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
    end

    it_behaves_like 'a successful exec'
  end

  context 'when input from stdin' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:args) { 'yaml _' }
      let(:expect_output) { "test\n" }

      it_behaves_like 'a successful exec'
    end

    describe 'Output UTF-8 string' do
      let(:input) { 'あいうえお🍣' }
      let(:args) { 'yaml _' }
      let(:expect_output) { "あいうえお🍣\n" }

      it_behaves_like 'a successful exec'
    end

    describe 'Output each object of the array one by one' do
      let(:input) { load_fixture('yaml/array.yml') }
      let(:args) { 'yaml _' }
      let(:expect_output) do
        <<~OUTPUT
          foo
          bar
          baz
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    describe 'Output only the filtered objects' do
      let(:input) { load_fixture('yaml/array.yml') }
      let(:args) { 'yaml /foo/' }
      let(:expect_output) { "foo\n" }

      it_behaves_like 'a successful exec'
    end

    describe 'Output the value of the selected Hash key' do
      let(:input) { load_fixture('yaml/hash.yml') }
      let(:args) { 'yaml "_.bar.baz"' }
      let(:expect_output) do
        <<~OUTPUT
          - a
          - b
          - c
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    describe 'Output the value of the selected Hash space included key' do
      let(:input) { load_fixture('yaml/hash.yml') }
      let(:args) { %q(yaml '_["foo bar"]') }
      let(:expect_output) { "foo bar\n" }

      it_behaves_like 'a successful exec'
    end

    describe 'Read all at once' do
      let(:input) { load_fixture('yaml/hash.yml') }
      let(:args) { "yaml -s -q 'p _'" }
      let(:expect_output) do
        "[{\"foo\" => 1, \"bar\" => {\"baz\" => [\"a\", \"b\", \"c\"]}, \"foo bar\" => \"foo bar\"}]\n"
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'when input from file' do
    describe 'Output string' do
      let(:file) { 'test.yml' }
      let(:input) { load_fixture('yaml/string.yml') }
      let(:args) { "yaml _ #{file}" }
      let(:expect_output) { "test\n" }

      before do
        write_file file, input
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'when suppress automatic printing' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:args) { 'yaml -q _' }
      let(:expect_output) { '' }

      it_behaves_like 'a successful exec'
    end
  end

  context 'when use regexp' do
    describe 'Input as String' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:args) { 'yaml /test/' }
      let(:expect_output) { "test\n" }

      it_behaves_like 'a successful exec'
    end

    describe 'Input as Number' do
      let(:input) { load_fixture('yaml/number.yml') }
      let(:args) { 'yaml /123456789/' }
      let(:expect_output) { "123456789\n" }

      it_behaves_like 'a successful exec'
    end

    describe 'Input as Hash' do
      let(:input) { 'foo: bar' }
      let(:args) { 'yaml /foo/' }
      let(:expect_output) { "foo: bar\n" }

      it_behaves_like 'a successful exec'
    end
  end

  context 'with --doc option' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:args) { 'yaml --doc _' }
      let(:expect_output) { "--- test\n" }

      it_behaves_like 'a successful exec'
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
    let(:args) { 'yaml nil' }
    let(:expect_output) { '' }

    it_behaves_like 'a successful exec'
  end
end
