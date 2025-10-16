module Rf
  module Filter
    class Yaml < Base
      def initialize(io)
        super

        yaml = YAML.load(io.read)
        @data = if yaml.instance_of?(Array)
                  yaml
                else
                  [yaml]
                end
      end

      def gets
        @data.shift
      end

      def size
        @data.size
      end

      def self.filename_extension
        'ya?ml'
      end
    end
  end
end
