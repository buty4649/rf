describe 'HashMashable features' do
  where do
    {
      'key is exist' => {
        args: 'json _.foo',
        expect_output: "\"bar\"\n"
      },
      'key is not exist' => {
        args: 'json _.piyo.class.to_s',
        expect_output: "\"NilClass\"\n"
      }
    }
  end

  with_them do
    let(:input) { '{"foo": "bar"}' }
    it_behaves_like 'a successful exec'
  end
end
