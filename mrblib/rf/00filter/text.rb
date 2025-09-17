module Rf
  module Filter
    class Text < Base
      class << self
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
            result += colorize? ? m.to_s.red : m.to_s
            record = m.post_match
          end

          result.empty? ? nil : "#{result}#{record}"
        end
      end

      def initialize(io)
        super

        fs = self.class.config[:filed_separator]
        $; = Regexp.new(fs) if fs
      end

      def gets
        io.gets&.chomp
      end
    end
  end
end
