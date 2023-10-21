module Rf
  class NotFound < StandardError
    def initialize(file)
      super "file not found: #{file}"
    end
  end

  class SyntaxError < StandardError; end
end
