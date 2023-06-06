module Rf
  module Filter
    class Base
      attr_reader :data, :record, :index

      def each_with_index
        index = 0
        data.each do |record|
          @record = record
          @index = index
          yield @record, @index
          index += 1
        end
      end

      def output(val)
        return if quiet?(val)

        puts(case val
             when true, Regexp
               @record
             else
               val
             end)
      end

      def puts(val)
        $stdout.puts decorate(val)
      end

      def decorate(str)
        str.to_s
      end

      def quiet?(val)
        case val
        when true, String, Integer, Float, Array, Hash, MatchData
          false
        when Regexp
          !val.match?(@record)
        else
          true
        end
      end
    end
  end
end
