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
end
