module Rf
  module Filter
    class Text < Base
      Config = Struct.new(:fs)

      def self.config
        @config ||= Config.new
      end

      def initialize(io)
        super()

        @data = io
        fs = self.class.config.fs
        $; = Regexp.new(fs) if fs
      end

      def gets
        @data.gets&.chomp
      end
    end
  end
end
