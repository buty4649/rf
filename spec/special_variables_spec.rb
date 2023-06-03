describe 'Special Variables' do
  describe '$_' do
    let(:input) { 'foo' }
    let(:output) { input }

    before { run_rf('-q "puts $_"', input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end

  describe '_' do
    let(:input) { 'foo' }
    let(:output) { input }

    before { run_rf('-q "puts _"', input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end

  describe '$F' do
    let(:input) { 'foo bar baz' }
    let(:output) do
      <<~OUTPUT
        Array
        3
      OUTPUT
    end

    before { run_rf('-q "puts $F.class,$F.size"', input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end
end
