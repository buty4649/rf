module Rf
  module Filter
    class Base
      attr_reader :index

      def initialize
        @index = 0
      end

      def read
        raise NotImplementedError
      end

      def gets
        raise NotImplementedError
      end

      def format(val, record)
        raise NotImplementedError
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
