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

  describe '#match' do
    let(:input) { 'foo' }
    let(:output) { 'foo' }

    before { run_rf("'match(/foo/)'", input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end

  describe '#match?' do
    let(:input) { 'foo' }
    let(:output) { 'foo' }

    before { run_rf("'match?(/foo/)'", input) }

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
