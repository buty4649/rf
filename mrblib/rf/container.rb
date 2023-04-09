module Rf
  class Container
    attr_reader :input
    alias _ input

    def input=(data)
      @input = $F = $_ = data # rubocop:disable Style/GlobalVars
    end

    def string?
      _.instance_of?(String)
    end

    def hash?
      _.instance_of?(Hash)
    end

    %i[gsub gsub! match match? sub sub! tr tr!].each do |sym|
      define_method(sym) do |*args|
        _.__send__(sym, *args) if string?
      end
    end

    %i[dig].each do |sym|
      define_method(sym) do |*args|
        _.__send__(sym, *args) if hash?
      end
    end

    def method_missing(sym, *)
      return unless string? && (m = /\A_([1-9]\d*)\z/.match(sym.to_s))

      _.split[m[1].to_i - 1]
    end

    def at_exit(&block)
      @__at_exit__ ||= block
    end
  end
end
