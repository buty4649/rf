module Rf
  module Features
    module OnigRegexpExt
      def self.enable
        OnigRegexp.prepend self
      end

      module Regexp
        OCTET = /(?:[1-9]?\d|1\d\d|2[0-4]\d|25[0-5])/.to_s.freeze
        IPV4 = /(?:\b(?<!\d|\.)(?:#{OCTET}\.){3}#{OCTET}(?!\.|\d))/.to_s.freeze
      end

      def initialize(str, flag = nil, code = nil)
        s = str.gsub('(?&ipv4)', Regexp::IPV4)
        super(s, flag, code)
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
