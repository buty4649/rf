module Rf
  module Filter
    class Json < Base
      class << self
        def config
          @config ||= Struct.new(:raw, :boolean_mode).new.tap do |config|
            config.boolean_mode = true
          end
        end

        def configure(opt)
          opt.on('-r', '--raw-string', 'output raw strings') do
            config.raw = true
          end
          opt.on('--disable-boolean-mode', 'consider true/false/null as json literal') do
            config.boolean_mode = false
          end
        end

        def raw?
          config.raw
        end

        def boolean_mode?
          config.boolean_mode
        end

        def format(val, record)
          case val
          when String
            raw? ? val : val.to_json
          when MatchData
            record.to_json
          when Regexp
            val.match(record.to_s) { record.to_json }
          when true, false, nil
            boolean_or_nil_to_json(val, record)
          else
            val.to_json
          end
        end

        def boolean_or_nil_to_json(boolean_or_nil, record)
          if boolean_mode?
            record.to_json if boolean_or_nil == true
          else
            boolean_or_nil.to_json
          end
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
