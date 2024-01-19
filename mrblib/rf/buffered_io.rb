module Rf
  class BufferedIO
    BUFFER_SIZE = 96 * 1024 # 96KB

    def initialize(file_name, mode = 'r')
      @file = file_name == '-' ? $stdin : File.open(file_name, mode)
      @buffer = ''
      @end_of_file = false
      @binary = false
    end

    def binary?
      @binary
    end

    def gets
      return if @end_of_file

      line = ''
      loop do
        fill_buffer if @buffer.empty?
        break if @buffer.empty?

        newline_index = @buffer.index("\n")
        if newline_index
          line << @buffer.slice!(0..newline_index)
          break
        else
          line << @buffer.slice!(0..-1)
          @buffer.clear
        end
      end

      line.empty? ? nil : line
    end

    def read
      return if @end_of_file

      fill_buffer(nil)
      @buffer.empty? ? nil : @buffer.slice!(0..-1)
    end

    def close
      @file.close
    end

    private

    def fill_buffer(size = BUFFER_SIZE)
      read_data = @file.read(size)
      if read_data.nil? || read_data.empty?
        @end_of_file = true
      else
        @binary = true if /(?![\r\n\t])\p{Cntrl}/.match?(read_data)

        @buffer << read_data
      end
    end
  end
end
