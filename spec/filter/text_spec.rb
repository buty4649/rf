describe 'Text filter' do
  let(:input) do
    <<~INPUT
      1 foo
      2 bar
      3 baz
      4 foobar
    INPUT
  end

  context 'when use -t option' do
    describe 'Output all lines' do
      let(:output) { input }

      before { run_rf('-t text true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end

  context 'when input from stdin' do
    describe 'Output all lines' do
      let(:output) { input }

      before { run_rf('true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end

    describe 'Output only the second filed' do
      let(:output) do
        <<~OUTPUT
          foo
          bar
          baz
          foobar
        OUTPUT
      end

      before { run_rf('_2', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end

    describe 'Output only the lines that match the regexp' do
      let(:output) do
        <<~OUTPUT
          1 \e[31mfoo\e[0m
          4 \e[31mfoo\e[0mbar
        OUTPUT
      end

      before { run_rf('/foo/', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end

    describe 'Output only the substring that matches the regexp' do
      let(:output) do
        <<~OUTPUT
          foo
          foo
        OUTPUT
      end

      before { run_rf('match(/foo/)', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end

    describe 'Output the sum of all the values in the first column' do
      let(:output) do
        <<~OUTPUT
          10
        OUTPUT
      end

      before { run_rf('-q "s||=0; s+=_1; at_exit{ puts s }"', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end

    describe 'Output the uppercase letters' do
      let(:output) do
        <<~OUTPUT
          1 FOO
          2 BAR
          3 BAZ
          4 FOOBAR
        OUTPUT
      end

      before { run_rf('_.upcase', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end

  context 'when input from file' do
    describe 'Output all lines' do
      let(:file) { 'test.txt' }
      let(:output) { input }

      before do
        write_file file, input
        run_rf("true #{file}")
      end

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end

  context 'when suppress automatic printing' do
    describe 'Output all lines' do
      let(:output) { '' }

      before { run_rf('-q true', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end

  context 'when change the field separator' do
    describe 'Output only the second filed' do
      let(:input) do
        <<~INPUT
          1,foo
          2,bar
          3,baz
          4,foobar
        INPUT
      end
      let(:output) do
        <<~OUTPUT
          foo
          bar
          baz
          foobar
        OUTPUT
      end

      before { run_rf('-F, _2', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output_on_stdout output_string_eq output }
    end
  end
end
