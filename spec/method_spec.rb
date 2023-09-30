describe 'Method' do
  describe '#gsub' do
    let(:input) { 'foo' }
    let(:output) do
      <<~OUTPUT
        bar
        foo
      OUTPUT
    end

    before { run_rf(%q('puts gsub(/foo/, "bar"); _'), input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end

  describe '#gsub!' do
    let(:input) { 'foo' }
    let(:output) do
      <<~OUTPUT
        bar
        bar
      OUTPUT
    end

    before { run_rf(%q('puts gsub!(/foo/, "bar"); _'), input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end

  %w[match m].each do |method|
    describe "##{method}" do
      let(:input) do
        <<~INPUT
          1 foo bar
          2 foo baz
          3 foo qux
        INPUT
      end

      where do
        {
          'String' => {
            condition: '"2 foo baz"',
            output: {
              without_block: '2 foo baz',
              with_block: '2'
            }
          },
          'Regexp' => {
            condition: '/.*foo.*/',
            output: {
              without_block: <<~OUTPUT,
                1 foo bar
                2 foo baz
                3 foo qux
              OUTPUT
              with_block: %w[1 2 3].join("\n")
            }
          },
          'TrueClass' => {
            condition: '_1 == "3"',
            output: {
              without_block: '3 foo qux',
              with_block: 3
            }
          },
          'FalseClass' => {
            condition: '_1 == "4"',
            output: {
              without_block: '',
              with_block: ''
            }
          },
          'Integer' => {
            condition: '_2 =~ /foo/',
            output: {
              without_block: <<~OUTPUT,
                1 foo bar
                2 foo baz
                3 foo qux
              OUTPUT
              with_block: %w[1 2 3].join("\n")
            }
          },
          'NilClass' => {
            condition: '_2 =~ /hoge/',
            output: {
              without_block: '',
              with_block: ''
            }
          }
        }
      end

      with_them do
        context 'without block' do
          before { run_rf("'#{method} #{condition}'", input) }

          it { expect(last_command_started).to be_successfully_executed }
          it { expect(last_command_started).to have_output output_string_eq output[:without_block] }
        end

        context 'with block' do
          before { run_rf("'#{method} #{condition} { _1 }'", input) }

          it { expect(last_command_started).to be_successfully_executed }
          it { expect(last_command_started).to have_output output_string_eq output[:with_block] }
        end
      end
    end
  end

  describe '#match?' do
    let(:input) { 'foo' }
    let(:output) { 'foo' }

    before { run_rf("'match?(/foo/)'", input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end

  describe '#m?' do
    let(:input) { 'foo' }
    let(:output) { 'foo' }

    before { run_rf("'m? /foo/'", input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end

  describe '#sub' do
    let(:input) { 'foofoo' }
    let(:output) do
      <<~OUTPUT
        barfoo
        foofoo
      OUTPUT
    end

    before { run_rf(%q('puts sub(/foo/, "bar"); _'), input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end

  describe '#sub!' do
    let(:input) { 'foofoo' }
    let(:output) do
      <<~OUTPUT
        barfoo
        barfoo
      OUTPUT
    end

    before { run_rf(%q('puts sub!(/foo/, "bar"); _'), input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end

  describe '#tr' do
    let(:input) { 'foo' }
    let(:output) do
      <<~OUTPUT
        FOO
        foo
      OUTPUT
    end

    before { run_rf(%q('puts tr("a-z", "A-Z"); _'), input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end

  describe '#tr!' do
    let(:input) { 'foo' }
    let(:output) do
      <<~OUTPUT
        FOO
        FOO
      OUTPUT
    end

    before { run_rf(%q('puts tr!("a-z", "A-Z"); _'), input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end
end
