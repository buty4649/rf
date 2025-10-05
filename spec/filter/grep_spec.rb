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

end
