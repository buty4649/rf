module Rf
  class Error < StandardError; end

  class NotFound < Error
    def initialize(file)
      super "file not found: #{file}"
    end
  end

  class IsDirectory < Error
    def initialize(path)
      super "#{path}: is a directory"
    end
  end

  class SyntaxError < Error; end
end
