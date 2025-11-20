describe 'MatchResult' do
  describe '#to_s' do
    context 'without capturing' do
      let(:input) { load_fixture('text/server_names.txt') }
      let(:args) { %("m /testserver-001.+(?&ipv4)/") }
      let(:expect_output) do
        <<~OUTPUT
          testserver-001 | ACTIVE | 192.168.100.1
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with capturing' do
      let(:input) { load_fixture('text/server_names.txt') }
      let(:args) { %("m /(testserver-001).+((?&ipv4))/") }
      let(:expect_output) do
        <<~OUTPUT
          testserver-001 192.168.100.1
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with empty string and empty matching regexp' do
      let(:input) { '' }
      let(:args) { %("//") }
      let(:expect_output) { '' }

      it_behaves_like 'a successful exec'
    end

    context 'with empty record and zero-width assertion' do
      let(:input) { '' }
      let(:args) { %("/^$/") }
      let(:expect_output) { '' }

      it_behaves_like 'a successful exec'
    end
  end
end
