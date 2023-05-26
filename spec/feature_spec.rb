describe 'Feature' do
  context 'for Integer' do
    where do
      {
        '#+' => {
          mark: '+',
          output: 2
        },
        '#-' => {
          mark: '-',
          output: 0
        },
        '#*' => {
          mark: '*',
          output: 1
        },
        '#/' => {
          mark: '/',
          output: 1
        }
      }
    end

    with_them do
      context 'when other is Integer' do
        let(:input) { '1' }

        before { run_rf("-q 'puts 1 #{mark} 1'", input) }

        it { expect(last_command_started).to be_successfully_executed }
        it { expect(last_command_started).to have_output output_string_eq output }
      end

      context 'when other is String' do
        let(:input) { '1' }

        before { run_rf("-q 'puts 1 #{mark} _1'", input) }

        it { expect(last_command_started).to be_successfully_executed }
        it { expect(last_command_started).to have_output output_string_eq output }
      end
    end
  end

  context 'for Float' do
    where do
      {
        '#+' => {
          mark: '+',
          output: 2.0
        },
        '#-' => {
          mark: '-',
          output: 0.0
        },
        '#*' => {
          mark: '*',
          output: 1.0
        },
        '#/' => {
          mark: '/',
          output: 1.0
        }
      }
    end

    with_them do
      context 'when other is Float' do
        let(:input) { '1' }

        before { run_rf("-q 'puts 1.0 #{mark} 1.0'", input) }

        it { expect(last_command_started).to be_successfully_executed }
        it { expect(last_command_started).to have_output output_string_eq output }
      end

      context 'when other is String' do
        let(:input) { '1' }

        before { run_rf("-q 'puts 1.0 #{mark} _1'", input) }

        it { expect(last_command_started).to be_successfully_executed }
        it { expect(last_command_started).to have_output output_string_eq output }
      end
    end
  end

  context 'for Hash' do
    describe 'auto accessor' do
      let(:input) { '{"foo": "bar"}' }
      let(:output) { '"bar"' }

      before { run_rf("-j '_.foo'", input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end
end
