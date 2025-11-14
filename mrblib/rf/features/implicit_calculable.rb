module Rf
  module Features
    module ImplicitCalculable
      def self.enable
        ::String.prepend String
        ::Integer.prepend Numeric
        ::Float.prepend Numeric
        ::NilClass.prepend NilClass
      end

      module String
        %i[< <= > >=].each do |op|
          define_method(op) do |other|
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

        def try_to_i
          Integer(self)
        rescue ArgumentError
          nil
        end

        def try_to_f
          Float(self)
        rescue ArgumentError
          nil
        end
      end

      module Numeric
        def self.prepended(*)
          %i[+ - * / < <= > >=].each do |op|
            define_method(op) do |other|
              o = if other.is_a?(String)
                    other.try_to_i || other.try_to_f || other
                  else
                    other
                  end
              super(o)
            end
          end
        end
      end

      module NilClass
        def +(other)
          if other.is_a?(Integer) || other.is_a?(Float)
            other
          elsif other.is_a?(String)
            other.try_to_i || other.try_to_f || other
          else
            raise TypeError, "no implicit conversion of nil into #{other.class}"
          end
        end

        def <<(other)
          [other]
        end
      end
    end
  end
end
