describe 'StringExt features' do
  describe 'String#binary?' do
    context 'when string contains null byte' do
      let(:input) { '' }
      let(:args) { %(-q 'p "hello\\x00world".binary?') }
      let(:expect_output) { "true\n" }

      it_behaves_like 'a successful exec'
    end

    context 'when string is valid UTF-8' do
      let(:input) { '' }
      let(:args) { %(-q 'p "hello world".binary?') }
      let(:expect_output) { "false\n" }

      it_behaves_like 'a successful exec'
    end

    context 'when string contains UTF-8 characters' do
      let(:input) { '' }
      let(:args) { %(-q 'p "こんにちは".binary?') }
      let(:expect_output) { "false\n" }

      it_behaves_like 'a successful exec'
    end

    context 'when string has invalid UTF-8 encoding' do
      let(:input) { '' }
      let(:args) { %(-q 'p "\\xff\\xfe".binary?') }
      let(:expect_output) { "true\n" }

      it_behaves_like 'a successful exec'
    end
  end
end
