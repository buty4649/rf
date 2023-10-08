module Rf
  class StreamIO
    def initialize(files)
      @files = files
      if files.empty?
        open_stdin
      else
        @files = files.dup
        open_next
      end
    end

    def gets
      if line = @current&.gets
        return line
      end

      return unless open_next

      gets
    end

    def each
      while line = gets
        yield line
      end
    end

    def read
      result = @current.read
      result += @current.read while open_next
      result
    end

    private

    def open_stdin
      @current = $stdin
    end

    def open_next
      @current = if file = @files.shift
                   File.open(file)
                 end
    rescue Errno::ENOENT
      raise NotFound, file
    end
  end
end
