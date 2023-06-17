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

      def read
        @data
      end

      def gets
        @data.shift
      end

      def decorate(val)
        return if quiet?(val)

        case val
        when MatchData, true
          decorate(record)
        when Regexp
          decorate_regexp(val)
        else
          val.to_yaml.sub(/\A---[\s\n]/, '')
        end
      end

      class RegexpUnsupportType < StandardError
        def initialize
          super('Regexp supports only String and Number records')
        end
      end

      def decorate_regexp(regexp)
        raise RegexpUnsupportType unless regexp_support_type?
        return unless regexp.match?(record.to_s)

        decorate(record)
      end

      def regexp_support_type?
        record.instance_of?(String) ||
          record.instance_of?(Integer) ||
          record.instance_of?(Float)
      end

      def quiet?(val)
        # false and nil is special character in YAML
        (val == false && record != false) ||
          (val.nil? && !record.nil?)
      end
    end
  end
end
