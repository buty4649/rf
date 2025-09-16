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
      add_features_to_string
      add_features_to_hash
      add_features_to_nil_class
      add_features_to_onigregexp_class
    end

    def add_features_to_integer
      extend_op(Integer, :to_i)
      compare_with_string(Integer, :try_to_i)
    end

    def add_features_to_float
      extend_op(Float, :to_f)
      compare_with_string(Float, :try_to_f)
    end

    def add_features_to_string
      %i[< <= > >=].each do |op|
        String.define_method(op) do |other|
          s = if other.is_a?(Integer)
                try_to_i || self
              elsif other.is_a?(Float)
                try_to_f || self
              else
                self
              end
          s.method(op).super_method.call(other)
        end
      end
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

    def compare_with_string(klass, convert_method)
      %i[< <= > >=].each do |op|
        klass.define_method(op) do |other|
          o = if other.respond_to?(convert_method)
                other.__send__(convert_method) || other
              else
                other
              end
          method(op).super_method.call(o)
        end
      end
    end

    def add_features_to_hash
      Hash.define_method(:method_missing) do |sym, *|
        fetch(sym.to_s, nil)
      end

      Hash.define_method(:respond_to_missing?) do
        true
      end
    end

    def add_features_to_nil_class
      NilClass.define_method(:+) do |other|
        if other.is_a?(Integer) || other.is_a?(Float)
          other
        elsif other.is_a?(String)
          other.try_to_i || other.try_to_f || other
        else
          raise TypeError, "no implicit conversion of nil into #{other.class}"
        end
      end

      NilClass.define_method(:<<) do |other|
        [other]
      end
    end

    def add_features_to_onigregexp_class
      OnigRegexp.class_eval do
        def on(str = $_)
          m = match(str)
          return m unless block_given?
          return if m.nil?

          yield(*$F)
        end
      end
    end
  end
end
