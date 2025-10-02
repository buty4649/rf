describe 'Show error message' do
  using RSpec::Parameterized::TableSyntax

  where(:args, :output) do
    '--invalid-option'     | 'Error: invalid option: --invalid-option'
    '-F'                   | 'Error: option requires an argument: -F'
    '_ not_found_file'     | 'Error: file not found: not_found_file'
    '_ .'                  | 'Error: .: is a directory'
    '-f program_file'      | 'Error: No such file or directory - open program_file'
    '-R -i _'              | 'Error: -R, -i: conflict options'
    'if'                   | 'Error: line 1: syntax error, unexpected end of file'
    '_.very_useful_method' | "Error: undefined method 'very_useful_method' for String"
    'unknown_method'       | "Error: undefined method 'unknown_method' for Rf::Container"
  end

  with_them do
    let(:input) { "test\n" }
    let(:expect_output) { "#{output}\n" }
    it_behaves_like 'a failed exec'
  end

  context 'when permission denied' do
    let(:file) { 'permission_denied_file' }
    let(:args) { "_ #{file}" }
    let(:expect_output) { "Error: #{file}: permission denied\n" }

    before do
      touch(file)
      if windows?
        # drop all permissions
        `icacls #{expand_path(file)} /inheritancelevel:r`
      else
        chmod(0o000, file)
      end
    end

    after do
      # restore permissions
      `icacls #{expand_path(file)} /inheritancelevel:e` if windows?
    end

    it_behaves_like 'a failed exec'
  end

  context 'when enable debug mode' do
    let(:input) { "test\n" }
    let(:args) { 'if' }
    let(:expect_output) do
      Regexp.new(Regexp.escape(<<~OUTPUT))
        Error: #<Rf::SyntaxError: line 1: syntax error, unexpected end of file>

        trace (most recent call last):
      OUTPUT
    end

    before do
      ENV['RF_DEBUG'] = 'y'
    end

    after do
      ENV['RF_DEBUG'] = nil
    end

    it_behaves_like 'a failed exec'
  end
end
