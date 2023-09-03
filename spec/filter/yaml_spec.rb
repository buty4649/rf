describe 'YAML filter' do
  context 'with -t option' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { 'test' }

      before { run_rf('-t yaml true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when input from stdin' do
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

    describe 'Read all at once' do
      let(:input) { load_fixture('yaml/hash.yml') }
      let(:output) do
        '[{"foo"=>1, "bar"=>{"baz"=>["a", "b", "c"]}, "foo bar"=>"foo bar"}]'
      end

      before { run_rf("-y -s -q 'p _'", input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when input from file' do
    describe 'Output string' do
      let(:file) { 'test.yml' }
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { 'test' }

      before do
        write_file file, input
        run_rf("-y true #{file}")
      end

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when suppress automatic printing' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { '' }

      before { run_rf('-q -y true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when use regexp' do
    describe 'Input as String' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { 'test' }

      before { run_rf('-y /test/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Input as Number' do
      let(:input) { load_fixture('yaml/number.yml') }
      let(:output) { '123456789' }

      before { run_rf('-y /123456789/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Input as Hash' do
      let(:input) { load_fixture('yaml/hash.yml') }
      let(:output) { 'Error: Regexp supports only String and Number records' }

      before { run_rf('-y /foo/', input) }

      it { expect(last_command_started).not_to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stderr output_string_eq output }
    end
  end

  context 'with --doc option' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { '--- test' }

      before { run_rf('-y --doc true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Output hash' do
      let(:input) { load_fixture('yaml/hash.yml') }
      let(:output) do
        <<~OUTPUT
          ---
          foo: 1
          bar:
            baz:
            - a
            - b
            - c
          foo bar: foo bar
        OUTPUT
      end

      before { run_rf('-y --doc true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end
end
