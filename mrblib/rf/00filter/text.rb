module Rf
  module Filter
    class Text < Base
      class << self
        def config
          @config ||= Struct.new(:fs).new
        end

        def configure(opt)
          opt.on('-F VAL', '--filed-separator', 'set the field separator (allow regexp)') do |v|
            config.fs = v
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
            val.map(&:to_s).join(' ')
          else
            val.to_s
          end
        end

        def regexp_to_text(regexp, record)
          result = ''
          while m = regexp.match(record)
            result += m.pre_match
            result += colorize ? m.to_s.red : m.to_s
            record = m.post_match
          end

          result.empty? ? nil : "#{result}#{record}"
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
