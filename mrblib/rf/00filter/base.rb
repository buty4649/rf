module Rf
  module Filter
    class Base
      def gets
        raise NotImplementedError
      end

      def self.format(val, record)
        raise NotImplementedError
      end

      def self.filename_extension; end

      def initialize(io)
        @io = io
      end

      protected

      attr_reader :io
    end
  end
end
