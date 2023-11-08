describe 'Global options' do
  context 'with -R option' do
    let(:output) do
      <<~OUTPUT
        ./a/b/c: abc
        ./foo/bar: foobar
      OUTPUT
    end

    before do
      FileUtils.mkdir_p(expand_path('a/b'))
      write_file('a/b/c', 'abc')
      FileUtils.mkdir_p(expand_path('foo'))
      write_file('foo/bar', 'foobar')

      run_rf('-R _ .')
    end

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end

  describe '-i/--in-place option' do
    let(:output) { '' }

    where(:option, :suffix) do
      [
        ['-i', ''],
        ['--in-place', ''],
        ['-i', '.bak'],
        ['--in-place=', '.bak']
      ]
    end

    with_them do
      before do
        write_file('foo', 'foo')
        run_rf(%(#{option}#{suffix} '"bar"' foo)).wait
      end

      let(:actucal) { read_file("foo#{suffix}") }

      it { expect(last_command_started).to be_successfully_executed }
      it { expect(last_command_started).to have_output output_string_eq output }
      it { expect(actucal).to eq "bar\n" }
    end
  end
end
