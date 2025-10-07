module Rf
  class Reader
    def initialize(file_name, mode = 'r')
      @file = file_name == '-' ? $stdin : File.open(file_name, mode)
    end

    def gets
      @file.readline
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
