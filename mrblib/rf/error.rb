module Rf
  class Error < StandardError; end

  class SyntaxError < Error; end
  class NoExpression < Error; end

  class NotFound < Error
    def initialize(file)
      super("file not found: #{file}")
    end
  end

  class IsDirectory < Error
    def initialize(path)
      super("#{path}: is a directory")
    end
  end

  class PermissionDenied < Error
    def initialize(path)
      super("#{path}: permission denied")
    end
  end

  class ConflictOptions < Error
    def initialize(options)
      opts = options.is_a?(Array) ? options.join(', ') : options
      super("#{opts}: conflict options")
    end
  end

  class NotRegularFile < Error
    def initialize(path)
      super("#{path}: not a regular file")
    end
  end
end
