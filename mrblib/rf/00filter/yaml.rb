module Rf
  module Filter
    class Yaml < Base
      Config = Struct.new(:no_doc)

      def self.config
        @config ||= Config.new(no_doc: true)
      end

      def no_doc?
        self.class.config.no_doc
      end

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

      def format(val, record)
        return unless result = obj_to_yaml(val, record)

        unpack_unicode_escape(
          no_doc? ? remove_doc_header(result) : result
        )
      end

      def obj_to_yaml(val, record)
        case val
        when MatchData
          record.to_yaml
        when Regexp
          record.to_yaml if val.match?(record.to_s)
        else
          val.to_yaml
        end
      end

      def unpack_unicode_escape(str)
        str.gsub(/\\u([0-9a-fA-F]{4})/) { [$1.to_i(16)].pack('U') }
           .gsub(/\\U([0-9a-fA-F]{8})/) { [$1.to_i(16)].pack('U') }
      end

      def remove_doc_header(str)
        str.sub(/\A---[\s\n]/, '')
      end
    end
  end
end
