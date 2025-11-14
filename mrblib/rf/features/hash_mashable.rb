module Rf
  module Features
    module HashMashable
      def self.enable
        ::Hash.prepend self
      end

      def method_missing(sym, *)
        fetch(sym, fetch(sym.to_s, nil))
      end

      def respond_to_missing?(sym, include_private)
        fetch(sym, fetch(sym.to_s, super))
      end
    end
  end
end
