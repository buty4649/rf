describe 'Array size' do
  let(:input) do
    # default array size max is 131072
    # src/array.c:21: #define MRB_ARY_LENGTH_MAX 131072
    140_000.times.to_a.join("\n")
  end

  let(:args) { '-s _.size' }
  let(:expect_output) { "140000\n" }

  it_behaves_like 'a successful exec'
end
