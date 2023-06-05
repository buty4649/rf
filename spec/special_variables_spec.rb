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
    context 'when record is String' do
      let(:input) { 'foo bar baz' }
      let(:output) do
        <<~OUTPUT
          "foo"
          "bar"
          "baz"
        OUTPUT
      end

      before { run_rf('-q "p $F[0],$F[1],$F[2]"', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    context 'when record is Hash' do
      let(:input) do
        <<~JSON
          {
            "a": 1,
            "b": 2,
            "c": 3
          }
        JSON
      end
      let(:output) do
        <<~OUTPUT
          ["a", 1]
          ["b", 2]
          ["c", 3]
        OUTPUT
      end

      before { run_rf('-j -q "p $F[0],$F[1],$F[2]"', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end

    context 'when record is Other class' do
      let(:input) { '1' }
      let(:output) do
        <<~OUTPUT
          1
          nil
          nil
        OUTPUT
      end

      before { run_rf('-j -q "p $F[0],$F[1],$F[2]"', input) }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
    end
  end

  describe '$.' do
    let(:input) do
      <<~TEXT
        foo
        bar
        baz
      TEXT
    end
    let(:output) do
      <<~OUTPUT
        1 foo
        2 bar
        3 baz
      OUTPUT
    end

    before { run_rf(%q/'[$.,_].join(" ")'/, input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end

  describe '@NR' do
    let(:input) do
      <<~TEXT
        foo
        bar
        baz
      TEXT
    end
    let(:output) do
      <<~OUTPUT
        1 foo
        2 bar
        3 baz
      OUTPUT
    end

    before { run_rf(%q/'[@NR,_].join(" ")'/, input) }

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end
end
