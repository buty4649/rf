module Rf
  module Filter
    class Yaml < Base
      class << self
        def config
          @config ||= Struct.new(:no_doc, :boolean_mode).new.tap do |config|
            config.no_doc = true
            config.boolean_mode = true
          end
        end

        def configure(opt)
          opt.on('--disable-boolean-mode', 'consider true/false/null as yaml literal') do
            config.boolean_mode = false
          end
          opt.on('--[no-]doc', '[no] output document sperator (refers to ---) (default:--no-doc)') do |v|
            config.no_doc = !v
          end
        end

        def no_doc?
          config.no_doc
        end

        def boolean_mode?
          config.boolean_mode
        end

        def format(val, record)
          return unless yaml_obj = obj_to_yaml(val, record)

          unpack_unicode_escape(
            no_doc? ? remove_doc_header(yaml_obj) : yaml_obj
          )
        end

        def obj_to_yaml(val, record)
          case val
          when MatchData
            record.to_yaml(colorize:)
          when Regexp
            val.match(record.to_s) { record.to_yaml }
          when true, false, nil
            boolean_or_nil_to_yaml(val, record)
          else
            val.to_yaml(colorize:)
          end
        end

        def boolean_or_nil_to_yaml(boolean_or_nil, record)
          if boolean_mode?
            record.to_yaml(colorize:) if boolean_or_nil == true
          else
            boolean_or_nil.to_yaml(colorize:)
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
