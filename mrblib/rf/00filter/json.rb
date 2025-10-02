module Rf
  module Filter
    class Json < Base
      class << self
        def raw?
          config[:raw?]
        end

        def boolean_mode?
          !config[:disable_boolean_mode?]
        end

        def pretty_print?
          !config[:minify?]
        end
        alias pretty_print pretty_print?

        def format(val, record)
          case val
          when String
            string_to_json(val)
          when MatchData
            record.to_json(colorize: colorize?, pretty_print: pretty_print?)
          when Regexp
            val.match(record.to_s) { record.to_json(colorize: colorize?, pretty_print: pretty_print?) }
          when true, false, nil
            boolean_or_nil_to_json(val, record)
          else
            val.to_json(colorize: colorize?, pretty_print: pretty_print?)
          end
        end

        def string_to_json(str)
          if raw?
            str
          else
            str.to_json(colorize: colorize?, pretty_print: pretty_print?)
          end
        end

        def boolean_or_nil_to_json(boolean_or_nil, record)
          if boolean_mode?
            record.to_json(colorize: colorize?, pretty_print: pretty_print?) if boolean_or_nil == true
          else
            boolean_or_nil.to_json(colorize: colorize?, pretty_print: pretty_print?)
          end
        end

        def filename_extension
          'json'
        end
      end

      def initialize(io)
        super

        json = JSON.parse(io.read)
        @data = if json.instance_of?(Array)
                  json
                else
                  [json]
                end
      end

      def gets
        @data.shift
      end
    end
  end
end
