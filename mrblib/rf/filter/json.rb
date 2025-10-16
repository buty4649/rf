module Rf
  module Filter
    class Json < Base
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

      def self.filename_extension
        'json'
      end
    end
  end
end
