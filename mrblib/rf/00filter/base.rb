module Rf
  module Filter
    class Base
      attr_reader :data

      def each_with_index
        index = 0
        data.each do |chunk|
          yield chunk, index
          index += 1
        end
      end

      def puts(str)
        $stdout.puts decorate(str)
      end

      def decorate(str)
        str.to_s
      end
    end
  end
end
