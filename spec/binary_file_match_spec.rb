describe 'Binary file match' do
  let(:binary_content) { "hello\x00\x80k\xb8\x00world\n" }

  context 'with basic binary detection' do
    it 'shows warning for stdin input' do
      run_rf('_', binary_content)
      expect(last_command_started.output).to eq "Warning: (stdin): binary file matches\n"
    end

    it 'shows warning with filename for file input' do
      file = 'binary_test.dat'
      write_file(file, binary_content)
      run_rf("_ #{file}")
      expect(last_command_started.output).to eq "Warning: #{file}: binary file matches\n"
    end

    it 'suppresses all output in quiet mode for stdin' do
      run_rf('-q _', binary_content)
      expect(last_command_started.output).to eq ''
    end

    it 'suppresses all output in quiet mode for file' do
      file = 'binary_quiet.dat'
      write_file(file, binary_content)
      run_rf("-q _ #{file}")
      expect(last_command_started.output).to eq ''
    end
  end

  describe 'non-binary content detection' do
    [
      ['regular text with tab', "hello\tworld\n"],
      ['ANSI color codes with \x0e', "hello\x0e[31mred text\x0e[0mworld\n"],
      ['ANSI escape sequences', "\x1b[31mhello\x1b[0m world\n"],
      ['Unicode emoji', "hello 😀 world\n"],
      ['various Unicode emojis', "🚀 rocket 🌟 star ⭐ another star\n"],
      ['Japanese text', "こんにちは世界\n"],
      ['mixed Unicode and ASCII', "Hello こんにちは 🌍 World\n"],
      ['special whitespace characters', "hello\u00A0world\u2003test\n"], # non-breaking space, em space
      ['various control characters', "hello\x07\x08\x09\x0A\x0B\x0C\x0D\x1B world\n"] # control chars
    ].each do |description, content|
      it "outputs #{description} normally without binary warning" do
        run_rf('_', content)
        expect(last_command_started.output).to eq content
      end
    end
  end

  describe 'multi-line files with mixed content' do
    let(:mixed_content) do
      [
        "This is a normal text line\n",
        "Another normal line\n",
        "This line has binary data: \x00\x80\xFF\n",
        "Back to normal text\n",
        "Final line with more binary: \x01\x02\x03\n",
        "Last normal line\n"
      ].join
    end

    let(:expected_mixed_output) do
      [
        "This is a normal text line\n",
        "Another normal line\n",
        "Back to normal text\n",
        "Final line with more binary: \x01\x02\x03\n",
        "Last normal line\n"
      ].join
    end

    it 'processes mixed binary/non-binary lines from stdin' do
      run_rf('_', mixed_content)
      expect(last_command_started.output).to eq "#{expected_mixed_output}Warning: (stdin): binary file matches\n"
    end

    it 'processes mixed binary/non-binary lines from file' do
      file = 'mixed_test.dat'
      write_file(file, mixed_content)
      run_rf("_ #{file}")
      expect(last_command_started.output).to eq "#{expected_mixed_output}Warning: #{file}: binary file matches\n"
    end

    [
      ['first line binary', "Binary first: \x00\xFF\nNormal second\nNormal third\n", "Normal second\nNormal third\n"],
      ['last line binary', "Normal first\nNormal second\nBinary last: \x00\xFF\n", "Normal first\nNormal second\n"],
      ['middle line binary', "Normal first\nBinary: \x00\xFF\nNormal last\n", "Normal first\nNormal last\n"]
    ].each do |description, content, expected|
      it "handles #{description}" do
        run_rf('_', content)
        expect(last_command_started.output).to eq "#{expected}Warning: (stdin): binary file matches\n"
      end
    end

    it 'suppresses output in quiet mode' do
      run_rf('-q _', mixed_content)
      expect(last_command_started.output).to eq ''
    end
  end

  describe 'filename in warning messages' do
    let(:test_binary) { "Binary: \x00\xFF\n" }

    [
      ['simple extension', 'test.txt'],
      ['with spaces', 'test file.dat', "'test file.dat'"],
      ['special chars', 'test-file_123.bin'],
      ['subdirectory', 'sub/test.dat', 'sub/test.dat', 'sub']
    ].each do |description, filename, quoted_name = nil, dir_to_create = nil|
      it "correctly shows #{description} in warning" do
        create_directory(dir_to_create) if dir_to_create
        write_file(filename, test_binary)
        run_rf("_ #{quoted_name || filename}")
        expect(last_command_started.output).to eq "Warning: #{filename}: binary file matches\n"
      end
    end

    it 'shows (stdin) for stdin input' do
      run_rf('_', test_binary)
      expect(last_command_started.output).to eq "Warning: (stdin): binary file matches\n"
    end

    it 'shows filename for file input' do
      write_file('test.bin', test_binary)
      run_rf('_ test.bin')
      expect(last_command_started.output).to eq "Warning: test.bin: binary file matches\n"
    end
  end
end
