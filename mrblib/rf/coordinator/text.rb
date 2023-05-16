module Rf
  module Coordinator
    class Text < Base
      def initialize(config, io)
        super
        @data = io
        $; = Regexp.new(config.text_fs) if config.text_fs
      end
    end
  end
end
