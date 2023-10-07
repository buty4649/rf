module Rf
  module Filter
    class Base
      def gets
        raise NotImplementedError
      end

      def format(val, record)
        raise NotImplementedError
      end

      def records
        Enumerator.new do |y|
          while record = gets
            y << record
          end
        end
      end

      def split(val)
        case val
        when Array
          val
        when Hash
          val.to_a
        when String
          val.split
        else
          [val]
        end
      end
    end
  end
end
