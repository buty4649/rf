module Rf
  module Filter
    class Text < Base
      class << self
        def config
          @config ||= Struct.new(:fs).new
        end

        def configure(opt)
          opt.on('-F VAL', '--filed-separator', 'set the field separator(regexp)') do |v|
            config.fs = v
          end
        end
      end

      def config
        self.class.config
      end

      def initialize(io)
        super()

        @data = io
        $; = Regexp.new(config.fs) if config.fs
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
