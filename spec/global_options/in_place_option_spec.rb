describe 'Behavior with in-place option' do
  using RSpec::Parameterized::TableSyntax

  where(:opts, :suffix) do
    '-i'          | ''
    '-i'          | '.bak'
    '--in-place'  | ''
    '--in-place=' | '.bak'
  end

  with_them do
    let(:args) do
      %(#{opts}#{suffix} '"bar"' foo)
    end
    let(:expect_output) { '' }

    before do
      write_file('foo', 'foo')
    end

    it_behaves_like 'a successful exec' do
      let(:file_content) { read_file("foo#{suffix}") }

      it { expect(file_content).to eq "bar\n" }
    end
  end

  context 'when multiple files are given' do
    before do
      write_file('test1', 'abc')
      write_file('test2', 'bac')
    end

    let(:args) do
      %(-i 'gsub(/a/, "A")' test1 test2)
    end
    let(:expect_output) { '' }

    it_behaves_like 'a successful exec' do
      let(:test1) { read_file('test1') }
      let(:test2) { read_file('test2') }

      it { expect(test1).to eq "Abc\n" }
      it { expect(test2).to eq "bAc\n" }
    end
  end
end
