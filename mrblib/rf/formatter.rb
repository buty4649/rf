module Rf
  module Formatter
    class << self
      def all
        @all ||= constants.select { |c| const_get(c) < Rf::Formatter::Base }
                          .to_h { |c| [c.downcase, const_get(c)] }
      end

      def load(type)
        unless formatter = all[type]
          raise ArgumentError,
                "Unknown filter type: #{type}. Available types: #{all.keys.join(', ')}"
        end

        formatter
      end
    end
  end
end
