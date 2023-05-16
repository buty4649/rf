module Rf
  module Coordinator
    class Yaml < Base
      def initialize(config, io)
        super
        yaml = YAML.load(io.read)
        @data = if yaml.instance_of?(Array)
                  yaml
                else
                  [yaml]
                end
      end

      def decorate(str)
        str.to_yaml
      end
    end
  end
end
