class Integer
  alias __add__ +
  alias __sub__ -
  alias __mul__ *
  alias __div__ / # bug: Highlight is broken after this line
end

class Float
  alias __add__ +
  alias __sub__ -
  alias __mul__ *
  alias __div__ / # bug: Highlight is broken after this line
end

module Rf
  class << self
    def add_features
      add_features_to_integer
      add_features_to_float
      add_features_to_hash
      add_features_to_json
    end

    def add_features_to_integer
      extend_op(Integer, :to_i)
    end

    def add_features_to_float
      extend_op(Float, :to_f)
    end

    def extend_op(klass, convert_method)
      {
        :+ => :__add__,
        :- => :__sub__,
        :* => :__mul__,
        :/ => :__div__
      }.each do |op, alias_name|
        klass.define_method(op) do |other|
          o = if other.respond_to?(convert_method)
                other.__send__(convert_method)
              else
                other
              end
          __send__(alias_name, o)
        end
      end
    end

    def add_features_to_hash
      Hash.define_method(:method_missing) do |sym, *args|
        fetch(sym.to_s) { super(sym, *args) }
      end

      Hash.define_method(:respond_to_missing?) do |sym, *|
        key?(sym.to_s) || super
      end
    end

    def add_features_to_json
      Object.define_method(:to_json) do
        JSON.pretty_generate(self)
      end
    end
  end
end
