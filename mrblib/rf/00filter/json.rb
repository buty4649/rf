module Rf
  module Filter
    class Json < Base
      Config = Struct.new(:raw)

      def self.config
        @config ||= Config.new
      end

      def raw?
        self.class.config.raw
      end

      def initialize(io) # rubocop:disable Lint/MissingSuper
        json = JSON.parse(io.read)
        @data = if json.instance_of?(Array)
                  json
                else
                  [json]
                end
      end

      def decorate(val)
        if raw? && val.instance_of?(String)
          val
        else
          JSON.pretty_generate(val)
        end
      end
    end
  end
end
