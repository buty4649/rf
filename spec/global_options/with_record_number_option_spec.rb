describe 'Behavior with --with-record-number option' do
  let(:input) do
    <<~INPUT
      foo
      bar
      baz
    INPUT
  end
  let(:args) { '--with-record-number --no-color _' }
  let(:expect_output) do
    <<~OUTPUT
      1:foo
      2:bar
      3:baz
    OUTPUT
  end

  it_behaves_like 'a successful exec'

  context 'with --color option' do
    let(:args) { '--with-record-number --color _' }
    let(:expect_output) do
      <<~OUTPUT
        \e[35m1\e[m\e[36m:\e[mfoo
        \e[35m2\e[m\e[36m:\e[mbar
        \e[35m3\e[m\e[36m:\e[mbaz
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'with --with-file-name option' do
    let(:args) { '--with-record-number --with-filename --no-color _ testfile' }
    let(:expect_output) do
      <<~OUTPUT
        testfile:1:foo
        testfile:2:bar
        testfile:3:baz
      OUTPUT
    end

    before do
      write_file 'testfile', input
    end

    it_behaves_like 'a successful exec'

    context 'with --color option' do
      let(:args) { '--with-record-number --with-filename --color _ testfile' }
      let(:expect_output) do
        <<~OUTPUT
          \e[35mtestfile\e[m\e[36m:\e[m\e[35m1\e[m\e[36m:\e[mfoo
          \e[35mtestfile\e[m\e[36m:\e[m\e[35m2\e[m\e[36m:\e[mbar
          \e[35mtestfile\e[m\e[36m:\e[m\e[35m3\e[m\e[36m:\e[mbaz
        OUTPUT
      end

      before do
        write_file 'testfile', input
      end

      it_behaves_like 'a successful exec'
    end
  end
end
