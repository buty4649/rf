describe 'Behavior with --with-record-number option' do
  let(:input) do
    <<~INPUT
      foo
      bar
      baz
    INPUT
  end
  let(:args) { '--with-record-number _' }
  let(:expect_output) do
    <<~OUTPUT
      1:foo
      2:bar
      3:baz
    OUTPUT
  end

  it_behaves_like 'a successful exec'

  context 'with --with-file-name option' do
    let(:args) { '--with-record-number --with-filename _ testfile' }
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
  end
end
