module Rf
  module Filter
    class InvalidType < StandardError
      def initialize(type)
        super(%("#{type}" is invalid type. possible values: #{Filter.filters.keys.join(',')}))
      end
    end

    class << self
      def filters
        @filters ||= constants.select { |c| const_get(c) < Rf::Filter::Base }
                              .to_h { |c| [c.downcase, const_get(c)] }
      end

      def load(type)
        raise InvalidType, type unless filter = filters[type]

        filter
      end
    end
  end
end
