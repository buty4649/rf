describe 'Show help text' do
  let(:expect_output) do
    pattern = <<~USAGE
      Usage:
        rf .+
        rf .+

      Commands:
        text .+
        json .+
        yaml .+
        version .+
        help .+
    USAGE
    Regexp.new("^#{pattern}.+$", Regexp::MULTILINE)
  end

  where(:args) do
    ['', 'help', '-h', '--help']
  end

  with_them do
    it_behaves_like 'a successful exec'
  end

  %w[text json yaml].each do |command|
    context "when use #{command} command" do
      let(:expect_output) do
        pattern = <<~USAGE
          Usage:
            rf #{command} .+
            rf #{command} .+

          Options:
        USAGE
        Regexp.new("^#{pattern}.+$", Regexp::MULTILINE)
      end
      let(:args) { command }

      it_behaves_like 'a successful exec'
    end
  end
end
