describe 'YAML filter', type: :aruba do
  context 'Use -t option' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { 'test' }
      before { run_rf('-t yaml true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'Input from stdin' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { 'test' }
      before { run_rf('-y true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Output each object of the array one by one' do
      let(:input) { load_fixture('yaml/array.yml') }
      let(:output) do
        <<~OUTPUT
          foo
          bar
          baz
        OUTPUT
      end
      before { run_rf('-y true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Output only the filtered objects' do
      let(:input) { load_fixture('yaml/array.yml') }
      let(:output) { 'foo' }
      before { run_rf('-y /foo/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Output the value of the selected Hash key' do
      let(:input) { load_fixture('yaml/hash.yml') }
      let(:output) do
        <<~OUTPUT
          - a
          - b
          - c
        OUTPUT
      end
      before { run_rf('-y "_.bar.baz"', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Output the value of the selected Hash space included key' do
      let(:input) { load_fixture('yaml/hash.yml') }
      let(:output) { 'foo bar' }
      before { run_rf(%q(-y '_["foo bar"]'), input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'Input from file' do
    describe 'Output string' do
      let(:file) { 'test.yml' }
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { 'test' }
      before { write_file file, input }
      before { run_rf("-y true #{file}") }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'Suppress automatic printing' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { '' }
      before { run_rf('-q -y true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end
end
