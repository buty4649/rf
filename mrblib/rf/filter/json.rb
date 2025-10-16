module Rf
  module Filter
    class Json < Base
      class << self
        def raw?
          config[:raw?]
        end

        def pretty_print?
          !config[:minify?]
        end
        alias pretty_print pretty_print?

        def format(val)
          case val
          when String
            string_to_json(val)
          when MatchResult
            JSON.generate(val.record, colorize: colorize?, pretty_print: pretty_print?)
          else
            JSON.generate(val, colorize: colorize?, pretty_print: pretty_print?)
          end
        end

        def string_to_json(str)
          if raw?
            str
          else
            JSON.generate(str, colorize: colorize?, pretty_print: pretty_print?)
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

      def size
        @data.size
      end
    end
  end
end
