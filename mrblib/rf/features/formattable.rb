module Rf
  module Features
    module Formattable
      def self.enable
        ::Object.prepend Object
        ::Array.prepend Array
        ::Hash.prepend Hash
      end

      module Object
        %w[json yaml].each do |type|
          method_name = :"to_#{type}"
          define_method(method_name) do
            val = respond_to?(:record) ? record : self

            filter_class = Rf::Formatter.load(type.to_sym)
            Rf::FormattedString.new(filter_class.format(val))
          end
        end
      end

      module Array
        def to_table
          Rf::FormattedString.new(Rf::Formatter::Table.format(self))
        end

        def to_ssv
          Rf::FormattedString.new(Rf::Formatter::Ssv.format(self))
        end
        alias to_v to_ssv
      end

      module Hash
        def to_table
          Rf::FormattedString.new(Rf::Formatter::Table.format(self))
        end
      end
    end
  end
end
