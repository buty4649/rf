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

      where do
        {
          'key is exist' => {
            command: '_.foo',
            output: '"bar"'
          },
          'key is not exist' => {
            command: '_.piyo',
            output: 'null'
          }
        }
      end

      with_them do
        before { run_rf("-j '#{command}'", input) }

        it { expect(last_command_started).to be_successfully_executed }
        it { expect(last_command_started).to have_output output_string_eq output }
      end
    end
  end

  describe 'to_json' do
    let(:input) { load_fixture('json/hash.json') }
    let(:output) do
      before { run_rf("-j -q 'puts _.to_json'", input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'for NilClass' do
    describe '#+' do
      where do
        {
          'Integer' => {
            input: %w[1 2 3].join("\n"),
            output: '6'
          },
          'Float' => {
            input: %w[1.1 2.2 3.3].join("\n"),
            output: '6.6'
          },
          'String' => {
            input: %w[foo bar baz].join("\n"),
            output: 'foobarbaz'
          }
        }
      end

      with_them do
        before { run_rf("-q 's+=_1; at_exit { puts s }'", input) }

        it { expect(last_command_started).to be_successfully_executed }
        it { expect(last_command_started).to have_output output_string_eq output }
      end
    end

    describe '#<<' do
      let(:input) { %w[foo bar baz].join("\n") }
      let(:output) { '["foo", "bar", "baz"]' }

      before { run_rf("-q 's <<= _1; at_exit { p s }'", input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end
end
