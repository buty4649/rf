describe 'Global options' do
  context 'with -R option' do
    let(:output) do
      <<~OUTPUT
        ./foo/bar: foobar
        ./a/b/c: abc
      OUTPUT
    end

    before do
      FileUtils.mkdir_p(expand_path('foo'))
      write_file('foo/bar', 'foobar')
      FileUtils.mkdir_p(expand_path('a/b'))
      write_file('a/b/c', 'abc')

      run_rf('-R _ .')
    end

    it { expect(last_command_started).to be_successfully_executed }
    it { expect(last_command_started).to have_output output_string_eq output }
  end
end
