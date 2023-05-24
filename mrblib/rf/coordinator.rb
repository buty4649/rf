module Rf
  module Coordinator
    class InvalidType < StandardError
      def initialize(type)
        super(%("#{type}" is invalid type. possible values: #{Coordinator.types.join(',')}))
      end
    end

    FILTERS = {
      text: Text,
      json: Json,
      yaml: Yaml
    }

    def self.types
      FILTERS.keys
    end

    def self.load(type)
      raise InvalidType, type unless filter = FILTERS[type.to_sym]

      filter
    end

    def self.all_filters
      FILTERS.values
    end
  end
end
