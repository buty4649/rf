describe 'to_json' do
  let(:input) { '' }
  let(:args) do
    %('{"foo": "bar"}.to_json')
  end

  let(:expect_output) do
    <<~OUTPUT
      {
        "foo": "bar"
      }
    OUTPUT
  end

  it_behaves_like 'a successful exec'
end
