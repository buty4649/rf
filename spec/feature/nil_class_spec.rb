describe 'Extended addition feature for NilClass' do
  using RSpec::Parameterized::TableSyntax

  describe '#+' do
    where(:input, :expect_output) do
      %w[1 2 3].join("\n")       | '6'
      %w[1.1 2.2 3.3].join("\n") | '6.6'
      %w[foo bar baz].join("\n") | 'foobarbaz'
    end

    with_them do
      let(:args) do
        %w[-q 's+=_1; at_exit { puts s }']
      end

      it_behaves_like 'a successful exec'
    end
  end

  describe '#<<' do
    let(:input) { %w[foo bar baz].join("\n") }
    let(:args) do
      %w[-q 's<<=_1; at_exit { puts s }']
    end
    let(:expect_output) { '["foo", "bar", "baz"]' }

    it_behaves_like 'a successful exec'
  end
end
