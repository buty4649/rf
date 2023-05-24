describe 'JSON filter', type: :aruba do
  context 'Input from stdin' do
    describe 'Output string' do
      let(:input) { load_fixture('json/string.json') }
      let(:output) { '"test"' }
      before { run_rf('-j true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end

    describe 'Output each object of the array one by one' do
      let(:input) { load_fixture('json/array.json') }
      let(:output) do
        <<~OUTPUT
          "foo"
          "bar"
          "baz"
        OUTPUT
      end
      before { run_rf('-j true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end

    describe 'Output only the filtered objects' do
      let(:input) { load_fixture('json/array.json') }
      let(:output) { '"foo"' }
      before { run_rf('-j /foo/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end

    describe 'Output the value of the selected Hash key' do
      let(:input) { load_fixture('json/hash.json') }
      let(:output) do
        <<~OUTPUT
          [
            "a",
            "b",
            "c"
          ]
        OUTPUT
      end
      before { run_rf('-j "_.bar.baz"', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end

    describe 'Output the value of the selected Hash space included key' do
      let(:input) { load_fixture('json/hash.json') }
      let(:output) { '"foo bar"' }
      before { run_rf(%q(-j '_["foo bar"]'), input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end

  context 'Input from file' do
    describe 'Output string' do
      let(:file) { 'test.txt' }
      let(:input) { load_fixture('json/string.json') }
      let(:output) { '"test"' }
      before { write_file file, input }
      before { run_rf("-j true #{file}") }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end

  context 'Suppress automatic printing' do
    describe 'Output string' do
      let(:input) { load_fixture('json/string.json') }
      let(:output) { '' }
      before { run_rf('-q -j true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end
end
