module Rf
  module Formatter
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
              YAML.dump(val, colorize: colorize?)
            end
          when MatchResult
            YAML.dump(val.record, colorize: colorize?)
          else
            YAML.dump(val, colorize: colorize?)
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
    end
  end
end
