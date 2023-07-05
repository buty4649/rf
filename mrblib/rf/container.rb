module Rf
  class Container
    def _
      $_
    end

    def _=(data)
      $_ = data
    end

    alias record _
    alias record= _=

    def fields
      $F
    end

    def fields=(data)
      $F = data
    end

    def string?
      _.instance_of?(String)
    end

    def hash?
      _.instance_of?(Hash)
    end

    %i[gsub gsub! match match? sub sub! tr tr!].each do |sym|
      define_method(sym) do |*args, &block|
        _.__send__(sym, *args, &block) if string?
      end
    end

    %i[dig].each do |sym|
      define_method(sym) do |*args|
        _.__send__(sym, *args) if hash?
      end
    end

    def respond_to_missing?(sym, *)
      # check for _0, _1, _2, _3, ...
      sym.to_s =~ /\A_(0|[1-9]\d*)\z/ || super
    end

    def method_missing(sym, *)
      s = sym.to_s
      # check for _0, _1, _2, _3, ...
      if sym == :_0
        _
      elsif s =~ /\A_[1-9]\d*\z/
        $F[s[1..].to_i - 1]
      else
        super
      end
    end

    def at_exit(&block)
      @__at_exit__ ||= block
    end
  end
end
