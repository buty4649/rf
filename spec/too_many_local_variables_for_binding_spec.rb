describe 'Too many local variables for binding' do
  # see. https://github.com/buty4649/rf/issues/145
  let(:input) { 239.times.to_a.join("\n") }
  let(:args) { '-q "v = 0"' }
  let(:expect_output) { '' }

  it_behaves_like 'a successful exec'
end
