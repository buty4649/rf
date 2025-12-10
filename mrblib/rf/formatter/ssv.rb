module Rf
  module Formatter
    class Ssv < Base
      class << self
        def format(val)
          if val.is_a?(Array)
            val.join(' ')
          elsif val.is_a?(Hash)
            val.map { |(k, v)| "#{k} #{v}" }.join("\n")
          elsif val.respond_to?(:to_s)
            to_s
          else
            NotImplementedError
          end
        end
      end
    end
  end
end
