module Rf
  module Formatter
    class Base64 < Base
      def self.format(val)
        return '' if val.nil?

        ::Base64.encode(val.to_s)
      end
    end
  end
end
