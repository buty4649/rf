module Rf
  module Filter
    class Json < Base
      class << self
        def config
          @config ||= Struct.new(:raw, :boolean_mode, :minify).new.tap do |config|
            config.boolean_mode = true
            config.minify = false
          end
        end

        def configure(opt)
          opt.on('-r', '--raw-string', 'output raw strings') do
            config.raw = true
          end
          opt.on('--disable-boolean-mode', 'consider true/false/null as json literal') do
            config.boolean_mode = false
          end
          opt.on('-m', '--minify', 'minify json output') do
            config.minify = true
          end
        end

        def raw?
          config.raw
        end

        def boolean_mode?
          config.boolean_mode
        end

        def pretty_print
          !config.minify
        end

        def format(val, record)
          case val
          when String
            string_to_json(val)
          when MatchData
            record.to_json(colorize:, pretty_print:)
          when Regexp
            val.match(record.to_s) { record.to_json(colorize:, pretty_print:) }
          when true, false, nil
            boolean_or_nil_to_json(val, record)
          else
            val.to_json(colorize:, pretty_print:)
          end
        end

        def string_to_json(str)
          if raw?
            if colorize
              JSON.colorize(str, JSON.color_string)
            else
              str
            end
          else
            str.to_json(colorize:, pretty_print:)
          end
        end

        def boolean_or_nil_to_json(boolean_or_nil, record)
          if boolean_mode?
            record.to_json(colorize:, pretty_print:) if boolean_or_nil == true
          else
            boolean_or_nil.to_json(colorize:, pretty_print:)
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
