module Rf
  module Filter
    class Yaml < Base
      def initialize(io)
        super()

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

      def decorate(val)
        val.to_yaml.sub(/\A---[\s\n]/, '')
      end
    end
  end
end
