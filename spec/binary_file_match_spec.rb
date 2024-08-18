describe 'Binary file match' do
  let(:content) { "hello\x00\x80k\xb8\x00world\n" }

  context 'when input is from stdin' do
    let(:input) { content }
    let(:args) { '_' }
    let(:expect_output) { "Binary file matches.\n" }

    it_behaves_like 'a successful exec'
  end

  context 'when input is from file' do
    let(:file) { 'binary_file' }
    let(:args) { "_ #{file}" }
    let(:expect_output) { "Binary file matches.\n" }

    before do
      write_file(file, content)
    end

    it_behaves_like 'a successful exec'
  end

  describe 'non-binary file' do
    let(:input) { "hello\tworld\n" }
    let(:args) { '_' }
    let(:expect_output) { "hello\tworld\n" }

    it_behaves_like 'a successful exec'
  end
end
