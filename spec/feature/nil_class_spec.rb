describe 'Extended addition feature for NilClass' do
  using RSpec::Parameterized::TableSyntax

  describe '#+' do
    where(:input, :expect_output) do
      %w[1 2 3].join("\n")       | "6\n"
      %w[1.1 2.2 3.3].join("\n") | "6.6\n"
      %w[foo bar baz].join("\n") | "foobarbaz\n"
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
      %w[-q 's<<=_1; at_exit { p s }']
    end
    let(:expect_output) do
      <<~OUTPUT
        ["foo", "bar", "baz"]
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end
end
