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

      def format(val, record)
        case val
        when String, false, nil
          val
        when true
          record
        when Regexp
          return unless m = val.match(record)

          [
            m.pre_match,
            m.to_s.red,
            m.post_match
          ].join
        when Array
          val.map(&:to_s).join("\n")
        else
          val.to_s
        end
      end
    end
  end
end
