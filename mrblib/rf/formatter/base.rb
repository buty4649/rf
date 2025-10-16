module Rf
  module Formatter
    class Base
      class << self
        def config
          Config.current
        end

        def colorize?
          config.color?
        end

        def format(val)
          raise NotImplementedError
        end

        def match(regexp, record)
          regexp.match(record.to_s)
        end
      end
    end
  end
end
