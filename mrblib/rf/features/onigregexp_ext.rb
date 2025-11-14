module Rf
  module Features
    module OnigRegexpExt
      def self.enable
        OnigRegexp.prepend self
      end

      def on(str = $_)
        m = match(str)
        return m unless block_given?
        return if m.nil?

        yield(*$F)
      end
    end
  end
end
