module Rf
  class Reader
    def initialize(file_name, mode = 'r')
      @file = file_name == '-' ? $stdin : File.open(file_name, mode)
      @binary = false
    end

    def binary?
      @binary
    end

    def gets
      line = @file.readline
      @binary = true if /(?![\r\n\t])\p{Cntrl}/.match?(line)
      line
    rescue EOFError
      nil
    end

    def read
      @file.read
    end

    def close
      @file.close
    end
  end
end
