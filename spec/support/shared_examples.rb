shared_examples 'a successful exec' do |_|
  before do
    run_rf(args, (input if defined?(input)))
  end

  describe 'exit status' do
    it 'is success' do
      expect(last_command_started).to be_successfully_executed
    end
  end

  describe 'output' do
    it 'is expected output' do
      expect(last_command_started.output).to match expect_output
    end
  end
end

shared_examples 'a failed exec' do |_|
  before do
    run_rf(args, (input if defined?(input)))
  end

  describe 'exit status' do
    it 'is failure' do
      expect(last_command_started).not_to be_successfully_executed
    end
  end

  describe 'output' do
    it 'is expected output' do
      expect(last_command_started.output).to match expect_output
    end
  end
end
