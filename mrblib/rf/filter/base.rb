module Rf
  module Filter
    class Base
      include Enumerable

      def initialize(io)
        return if io.is_a?(IO)

        raise ArgumentError
      end

      def each
        return to_enum(:each) { size } unless block_given?

        while record = gets
          yield record
        end

        self
      end

      def gets
        raise NotImplementedError
      end

      def size; end

      def self.filename_extension; end
    end
  end
end
