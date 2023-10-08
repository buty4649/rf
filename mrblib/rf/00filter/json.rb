module Rf
  module Filter
    class Json < Base
      class << self
        def config
          @config ||= Struct.new(:raw).new
        end

        def configure(opt)
          opt.on('-r', '--raw-string', 'output raw strings') do
            config.raw = true
          end
        end
      end

      def raw?
        self.class.config.raw
      end

      def initialize(io)
        super()

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

      def format(val, record)
        case val
        when String
          raw? ? val : val.to_json
        when MatchData
          record.to_json
        when Regexp
          record.to_json if val.match?(record.to_s)
        else
          val.to_json
        end
      end
    end
  end
end
