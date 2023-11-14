describe 'Behavior with recursive option' do
  where(:opts) do
    %w[-R --recursive]
  end

  with_them do
    let(:args) { "#{opts} _ ." }
    let(:expect_output) do
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
    end

    it_behaves_like 'a successful exec'
  end
end
