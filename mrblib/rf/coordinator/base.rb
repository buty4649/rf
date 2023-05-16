module Rf
  module Coordinator
    class Base
      attr :config, :data

      def initialize(config, *)
        @config = config
      end

      def each
        index = 1
        data.each do |input|
          yield input, index
        end
      end

      def puts(str)
        $stdout.puts decorate(str)
      end

      def decorate(str)
        str.to_s
      end
    end
  end
end
