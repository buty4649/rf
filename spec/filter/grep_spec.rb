describe 'Text filter with grep mode' do
  let(:input) { load_fixture('text/test.txt') }

  context 'with basic pattern matching' do
    let(:args) { 'grep foo' }
    let(:expect_output) do
      <<~OUTPUT
        1 foo
        4 foobar
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'with regex pattern' do
    let(:args) { 'grep "ba[rz]"' }
    let(:expect_output) do
      <<~OUTPUT
        2 bar
        3 baz
        4 foobar
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'with word boundary pattern' do
    let(:args) { 'grep "\\bbar\\b"' }
    let(:expect_output) do
      <<~OUTPUT
        2 bar
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'with line number option' do
    let(:args) { 'grep --with-record-number foo' }
    let(:expect_output) do
      <<~OUTPUT
        1:1 foo
        4:4 foobar
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'with filename option' do
    let(:args) { 'grep -H foo testfile' }
    let(:expect_output) do
      <<~OUTPUT
        testfile:1 foo
        testfile:4 foobar
      OUTPUT
    end

    before do
      write_file 'testfile', input
    end

    it_behaves_like 'a successful exec'
  end

  context 'with color output' do
    let(:args) { 'grep --color foo' }
    let(:expect_output) do
      <<~OUTPUT
        1 \e[31mfoo\e[m
        4 \e[31mfoo\e[mbar
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'with multiple files' do
    let(:args) { 'grep -H foo testfile1 testfile2' }
    let(:expect_output) do
      <<~OUTPUT
        testfile1:1 foo
        testfile1:4 foobar
        testfile2:1 foo
        testfile2:4 foobar
      OUTPUT
    end

    before do
      write_file 'testfile1', input
      write_file 'testfile2', input
    end

    it_behaves_like 'a successful exec'
  end

  context 'when no matches found' do
    let(:args) { 'grep xyz' }
    let(:expect_output) { '' }

    it_behaves_like 'a successful exec'
  end

  context 'with invert match (-v) option' do
    let(:args) { 'grep -v foo' }
    let(:expect_output) do
      <<~OUTPUT
        2 bar
        3 baz
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'with invert match (-v) and line number option' do
    let(:args) { 'grep -v --with-record-number foo' }
    let(:expect_output) do
      <<~OUTPUT
        2:2 bar
        3:3 baz
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'with invert match (-v) and filename option' do
    let(:args) { 'grep -v -H foo testfile' }
    let(:expect_output) do
      <<~OUTPUT
        testfile:2 bar
        testfile:3 baz
      OUTPUT
    end

    before do
      write_file 'testfile', input
    end

    it_behaves_like 'a successful exec'
  end

  context 'with invert match (-v) and color output' do
    let(:args) { 'grep -v --color foo' }
    let(:expect_output) do
      <<~OUTPUT
        2 bar
        3 baz
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'with recursive option' do
    let(:args) { 'grep -R foo .' }
    let(:expect_output) do
      <<~OUTPUT
        ./subdir/test.txt:1 foo
        ./subdir/test.txt:4 foobar
        ./test.txt:1 foo
        ./test.txt:4 foobar
      OUTPUT
    end

    before do
      write_file 'test.txt', input
      FileUtils.mkdir_p(expand_path('subdir'))
      write_file 'subdir/test.txt', input
      write_file 'subdir/other.log', 'no match here'
    end

    it_behaves_like 'a successful exec'
  end

  context 'with include filename pattern' do
    let(:args) { 'grep -R --include-filename "*.txt" foo .' }
    let(:expect_output) do
      <<~OUTPUT
        ./test.txt:1 foo
        ./test.txt:4 foobar
      OUTPUT
    end

    before do
      write_file 'test.txt', input
      write_file 'test.log', input
      write_file 'other.txt', 'no match'
    end

    it_behaves_like 'a successful exec'
  end

  context 'with case insensitive option (-i)' do
    let(:input_with_mixed_case) do
      <<~INPUT
        1 foo
        2 Bar
        3 BAZ
        4 FooBar
        5 test
      INPUT
    end

    before do
      write_file 'testfile', input_with_mixed_case
    end

    context 'when searching for lowercase pattern' do
      let(:args) { 'grep -i foo testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1 foo
          4 FooBar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'when searching for uppercase pattern' do
      let(:args) { 'grep -i BAR testfile' }
      let(:expect_output) do
        <<~OUTPUT
          2 Bar
          4 FooBar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'when searching for mixed case pattern' do
      let(:args) { 'grep -i BaZ testfile' }
      let(:expect_output) do
        <<~OUTPUT
          3 BAZ
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with line number option' do
      let(:args) { 'grep -i --with-record-number foo testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1:1 foo
          4:4 FooBar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with color output' do
      let(:args) { 'grep -i --color foo testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1 \e[31mfoo\e[m
          4 \e[31mFoo\e[mBar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with invert match (-v) option' do
      let(:args) { 'grep -i -v foo testfile' }
      let(:expect_output) do
        <<~OUTPUT
          2 Bar
          3 BAZ
          5 test
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'with case insensitive (-i) and expression (-e) options' do
    let(:input_with_mixed_case) do
      <<~INPUT
        1 foo
        2 Bar
        3 BAZ
        4 FooBar
        5 test
      INPUT
    end

    before do
      write_file 'testfile', input_with_mixed_case
    end

    context 'when using single -e option' do
      let(:args) { 'grep -i -e foo testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1 foo
          4 FooBar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'when using multiple -e options' do
      let(:args) { 'grep -i -e foo -e bar testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1 foo
          2 Bar
          4 FooBar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'when using multiple -e options with mixed case patterns' do
      let(:args) { 'grep -i -e FOO -e baz testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1 foo
          3 BAZ
          4 FooBar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with line number option and multiple -e' do
      let(:args) { 'grep -i --with-record-number -e foo -e bar testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1:1 foo
          2:2 Bar
          4:4 FooBar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with color output and multiple -e' do
      let(:args) { 'grep -i --color -e foo -e bar testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1 \e[31mfoo\e[m
          2 \e[31mBar\e[m
          4 \e[31mFoo\e[m\e[31mBar\e[m
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with invert match (-v) and multiple -e' do
      let(:args) { 'grep -i -v -e foo -e bar testfile' }
      let(:expect_output) do
        <<~OUTPUT
          3 BAZ
          5 test
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'with ignore case long option (--ignore-case)' do
    let(:input_with_mixed_case) do
      <<~INPUT
        1 foo
        2 Bar
        3 BAZ
        4 FooBar
        5 test
      INPUT
    end

    before do
      write_file 'testfile', input_with_mixed_case
    end

    context 'when searching for lowercase pattern' do
      let(:args) { 'grep --ignore-case foo testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1 foo
          4 FooBar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'when searching for uppercase pattern' do
      let(:args) { 'grep --ignore-case BAR testfile' }
      let(:expect_output) do
        <<~OUTPUT
          2 Bar
          4 FooBar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with line number option' do
      let(:args) { 'grep --ignore-case --with-record-number foo testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1:1 foo
          4:4 FooBar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with color output' do
      let(:args) { 'grep --ignore-case --color foo testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1 \e[31mfoo\e[m
          4 \e[31mFoo\e[mBar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end

  context 'with no ignore case option (--no-ignore-case)' do
    let(:input_with_mixed_case) do
      <<~INPUT
        1 foo
        2 Bar
        3 BAZ
        4 FooBar
        5 test
      INPUT
    end

    before do
      write_file 'testfile', input_with_mixed_case
    end

    context 'when searching for lowercase pattern' do
      let(:args) { 'grep --no-ignore-case foo testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1 foo
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'when searching for uppercase pattern' do
      let(:args) { 'grep --no-ignore-case BAR testfile' }
      let(:expect_output) { '' }

      it_behaves_like 'a successful exec'
    end

    context 'when searching for exact case match' do
      let(:args) { 'grep --no-ignore-case BAZ testfile' }
      let(:expect_output) do
        <<~OUTPUT
          3 BAZ
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with line number option' do
      let(:args) { 'grep --no-ignore-case --with-record-number foo testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1:1 foo
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with color output' do
      let(:args) { 'grep --no-ignore-case --color foo testfile' }
      let(:expect_output) do
        <<~OUTPUT
          1 \e[31mfoo\e[m
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end
end
