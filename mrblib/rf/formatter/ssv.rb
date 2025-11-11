class Array
  def to_ssv
    Rf::FormattedString.new(Rf::Formatter::Ssv.format(self))
  end
  alias to_v to_ssv
end

module Rf
  module Formatter
    class Ssv < Base
      class << self
        def format(val)
          if val.is_a?(Array)
            val.join(' ')
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
