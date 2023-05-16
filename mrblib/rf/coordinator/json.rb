module Rf
  module Coordinator
    class Json < Base
      def initialize(config, io)
        super
        json = JSON.parse(io.read)
        @data = if json.instance_of?(Array)
                  json
                else
                  [json]
                end
      end

      def decorate(str)
        JSON.pretty_generate(str)
      end
    end
  end
end
