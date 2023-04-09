module Rf
  module Coordinator
    def self.load(config, io)
      type = config.type
      case type
      when 'text'
        Coordinator::Text
      when 'json'
        Coordinator::Json
      when 'yaml'
        Coordinator::Yaml
      else
        $stderr.puts "Unknown parser: #{type}"
        exit 1
      end.new(config, io)
    end

    class Base
      attr :config, :data

      def initialize(config, *)
        @config = config
      end

      def each
        index = 1
        data.each do |input|
          yield input, index
        end
      end

      def decorate(str)
        str.to_s
      end
    end

    class Text < Base
      def initialize(config, io)
        super
        @data = io
        $; = Regexp.new(config.text_fs) if config.text_fs
      end
    end

    class Json < Base
      def initialize(config, io)
        super
        json = JSON.parse(io.read)
        @data = if json.instance_of?(Array)
                  json
                else
                  [json]
                end
      end

      def decorate(str)
        JSON.pretty_generate(str)
      end
    end

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
