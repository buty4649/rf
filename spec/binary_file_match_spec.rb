describe 'Binary file match' do
  context 'when input is from stdin' do
    let(:input) { "hello\x00world\n" }
    let(:args) { '_' }
    let(:expect_output) { 'Binary file matches.' }

    it_behaves_like 'a successful exec'
  end

  context 'when input is from file' do
    let(:file) { 'binary_file' }
    let(:args) { "_ #{file}" }
    let(:expect_output) { 'Binary file matches.' }

    before do
      write_file(file, "hello\x00world\n")
    end

    it_behaves_like 'a successful exec'
  end
end
