class Object
  %w[json yaml].each do |type|
    method_name = :"to_#{type}"
    define_method(method_name) do
      val = respond_to?(:record) ? record : self

      filter_class = Rf::Formatter.load(type.to_sym)
      Rf::FormattedString.new(filter_class.format(val))
    end
  end
end
