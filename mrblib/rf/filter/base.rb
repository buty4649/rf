module Rf
  module Filter
    class Base
      include Enumerable

      class << self
        def config
          Config.current
        end

        def colorize?
          config.color?
        end

        def format(val)
          raise NotImplementedError
        end

        def match(regexp, record)
          regexp.match(record.to_s)
        end

        def filename_extension; end
      end

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
    end
  end
end
