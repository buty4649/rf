module Rf
  module Filter
    class Text < Base
      def initialize(io)
        super

        @io = io
        fs = Config.current[:filed_separator]
        $; = Regexp.new(fs) if fs
      end

      def gets
        @io.gets&.chomp
      end
    end
  end
end
