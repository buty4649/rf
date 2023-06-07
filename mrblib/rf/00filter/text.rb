module Rf
  module Filter
    class Text < Base
      Config = Struct.new(:fs)

      def self.config
        @config ||= Config.new
      end

      def initialize(io) # rubocop:disable Lint/MissingSuper
        @data = io
        fs = self.class.config.fs
        $; = Regexp.new(fs) if fs
      end

      def preprocess(record)
        record.chomp
      end
    end
  end
end
