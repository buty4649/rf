module Rf
  module Filter
    class Base
      attr_reader :record, :index

      def initialize
        @index = 0
      end

      def gets
        NotImplementedError
      end

      # Increment index when gets is called
      def self.inherited(klass)
        klass.define_singleton_method(:method_added) do |name|
          if name == :gets && !method_defined?(:gets_without_increment)
            alias_method :gets_without_increment, :gets

            define_method(:gets) do
              return unless v = gets_without_increment

              @index += 1
              v
            end
          end

          super
        end

        super
      end

      def each_record
        while @record = gets
          fields = split(record)
          yield record, index, fields
        end
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

      def decorate(val)
        val.to_s
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
