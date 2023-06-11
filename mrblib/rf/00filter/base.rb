module Rf
  module Filter
    class Base
      attr_reader :data, :record, :index, :fields

      def each_record
        index = 1
        data.each do |record|
          @record = preprocess(record)
          @index = index
          @fields = split(@record)
          yield @record, @index, @fields
          index += 1
        end
      end

      def preprocess(record)
        record
      end

      def split(record)
        case record
        when Array
          record
        when Hash
          record.to_a
        when String
          record.split
        else
          [record]
        end
      end

      def output(val)
        return if quiet?(val)

        puts(case val
             when true, Regexp
               record
             else
               val
             end)
      end

      def puts(*args)
        args.each do |arg|
          $stdout.puts decorate(arg)
        end
      end

      def decorate(str)
        str.to_s
      end

      def quiet?(val)
        case val
        when true, String, Integer, Float, Array, Hash, MatchData
          false
        when Regexp
          !val.match?(record)
        else
          true
        end
      end
    end
  end
end
