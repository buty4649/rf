module Rf
  class StreamIO
    def initialize(files)
      if files.empty?
        @files = []
        @current = $stdin
      else
        @files = files.dup
        @current = self.open(@files.shift)
      end
    end

    def open(file)
      File.open(file)
    rescue Errno::ENOENT
      raise NotFound, file
    end

    def gets
      if line = @current.gets
        return line
      end

      return unless file = @files.shift

      @current = self.open(file)
      gets
    end

    def each
      while line = gets
        yield line
      end
    end

    def read
      @current.read + @files.map { |file| File.read(file) }.join
    end
  end
end
