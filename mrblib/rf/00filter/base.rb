module Rf
  module Filter
    class Base
      class << self
        def config
          Config.current
        end

        def colorize?
          config.color?
        end
      end

      def gets
        raise NotImplementedError
      end

      def binary?
        @io.binary?
      end

      def self.format(val, record)
        raise NotImplementedError
      end

      def self.match(regexp, record)
        regexp.match(record.to_s)
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
