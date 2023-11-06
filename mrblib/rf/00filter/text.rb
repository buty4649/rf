module Rf
  module Filter
    class Text < Base
      class << self
        def config
          @config ||= Struct.new(:fs, :color).new.tap do |c|
            c.color = true
          end
        end

        def configure(opt)
          opt.on('-F VAL', '--filed-separator', 'set the field separator (allow regexp)') do |v|
            config.fs = v
          end
          opt.on('--[no-]color', '[no] colorized output (default: --color)') do |v|
            config.color = v
          end
        end

        def format(val, record)
          case val
          when String, false, nil
            val
          when true
            record
          when Regexp
            regexp_to_text(val, record)
          when Array
            val.map(&:to_s).join("\n")
          else
            val.to_s
          end
        end

        def regexp_to_text(regexp, record)
          return unless m = regexp.match(record)

          text = m.to_s.then { |s| config.color ? s.red : s }
          [
            m.pre_match,
            text,
            m.post_match
          ].join
        end
      end

      def config
        self.class.config
      end

      def initialize(io)
        super

        $; = Regexp.new(config.fs) if config.fs
      end

      def gets
        io.gets&.chomp
      end
    end
  end
end
