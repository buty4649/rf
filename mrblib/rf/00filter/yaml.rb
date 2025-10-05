module Rf
  module Filter
    class Yaml < Base
      class << self
        def doc?
          config[:doc?]
        end

        def raw?
          config[:raw?]
        end

        def format(val)
          return unless yaml_obj = obj_to_yaml(val)

          unpack_unicode_escape(
            doc? ? yaml_obj : remove_doc_header(yaml_obj)
          )
        end

        def obj_to_yaml(val)
          case val
          when String
            if raw?
              val
            else
              val.to_yaml(colorize: colorize?)
            end
          when MatchResult
            val.record.to_yaml(colorize: colorize?)
          else
            val.to_yaml(colorize: colorize?)
          end
        end

        def unpack_unicode_escape(str)
          str.gsub(/\\u([0-9a-fA-F]{4})/) { [$1.to_i(16)].pack('U') }
             .gsub(/\\U([0-9a-fA-F]{8})/) { [$1.to_i(16)].pack('U') }
        end

        def remove_doc_header(str)
          str.sub(/\A---[\s\n]/, '')
        end

        def filename_extension
          'ya?ml'
        end
      end

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
    end
  end
end
