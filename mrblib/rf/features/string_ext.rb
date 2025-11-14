module Rf
  module Features
    module StringExt
      def self.enable
        ::String.prepend self
      end

      def binary?
        !!index("\x00") || !force_encoding('UTF-8').valid_encoding?
      end
    end
  end
end
