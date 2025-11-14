module Rf
  module Features
    def self.enable
      %i[
        Formattable ImplicitCalculable HashMashable
        StringExt OnigRegexpExt
      ].each do |f|
        const_get(f).enable
      end
    end
  end
end
