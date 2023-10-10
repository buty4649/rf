describe 'YAML filter' do
  context 'with -t option' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { 'test' }

      before { run_rf('-t yaml _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'with -r option' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/multibyte_string.yml') }
      let(:output) { '🍣🍣🍣' }

      before { run_rf('-t yaml -r _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when input from stdin' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { 'test' }

      before { run_rf('-y _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    describe 'Output UTF-8 string' do
      let(:input) { 'あいうえお🍣' }
      let(:output) { '"あいうえお🍣"' }

      before { run_rf('-y _', input) }

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

      before { run_rf('-y _', input) }

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
        run_rf("-y _ #{file}")
      end

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'when suppress automatic printing' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { '' }

      before { run_rf('-y -q _', input) }

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
      let(:input) { 'foo: bar' }
      let(:output) { input }

      before { run_rf('-y /foo/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  context 'with --doc option' do
    describe 'Output string' do
      let(:input) { load_fixture('yaml/string.yml') }
      let(:output) { '--- test' }

      before { run_rf('-y --doc _', input) }

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

      before { run_rf('-y --doc _', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  describe 'Output nil value' do
    let(:input) { 'foobar' }
    let(:output) { 'null' }

    before { run_rf('-y nil', input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end
end
