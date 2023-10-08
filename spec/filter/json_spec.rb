describe 'JSON filter' do
  context 'with -t option' do
    describe 'Output string' do
      let(:input) { load_fixture('json/string.json') }
      let(:output) { '"test"' }

      before { run_rf('-t json _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'with -r option' do
    describe 'Output string' do
      let(:input) { load_fixture('json/string.json') }
      let(:output) { 'test' }

      before { run_rf('-j -r _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when input from stdin' do
    describe 'Output string' do
      let(:input) { load_fixture('json/string.json') }
      let(:output) { '"test"' }

      before { run_rf('-j _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
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

      before { run_rf('-j _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Output only the filtered objects' do
      let(:input) { load_fixture('json/array.json') }
      let(:output) { '"foo"' }

      before { run_rf('-j /foo/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
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
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Output the value of the selected Hash space included key' do
      let(:input) { load_fixture('json/hash.json') }
      let(:output) { '"foo bar"' }

      before { run_rf(%q(-j '_["foo bar"]'), input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Read all at once' do
      let(:input) { load_fixture('json/hash.json') }
      let(:output) do
        '[{"foo"=>1, "bar"=>{"baz"=>["a", "b", "c"]}, "foo bar"=>"foo bar"}]'
      end

      before { run_rf("-j -s -q 'p _'", input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when input from file' do
    describe 'Output string' do
      let(:file) { 'test.json' }
      let(:input) { load_fixture('json/string.json') }
      let(:output) { '"test"' }

      before do
        write_file file, input
        run_rf("-j _ #{file}")
      end

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when suppress automatic printing' do
    describe 'Output string' do
      let(:input) { load_fixture('json/string.json') }
      let(:output) { '' }

      before { run_rf('-j -q _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when use regexp' do
    describe 'Input as String' do
      let(:input) { load_fixture('json/string.json') }
      let(:output) { '"test"' }

      before { run_rf('-j /test/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Input as Number' do
      let(:input) { load_fixture('json/number.json') }
      let(:output) { '123456789' }

      before { run_rf('-j /123456789/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Input as Hash' do
      let(:input) { '{"foo": "bar"}' }
      let(:output) do
        <<~OUTPUT
          {
            "foo":"bar"
          }
        OUTPUT
      end

      before { run_rf('-j /foo/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end
end
