module Rf
  module Filter
    class Json < Base
      Config = Struct.new(:raw)

      def self.config
        @config ||= Config.new
      end

      def raw?
        self.class.config.raw
      end

      def initialize(io)
        super()

        json = JSON.parse(io.read)
        @data = if json.instance_of?(Array)
                  json
                else
                  [json]
                end
      end

      def gets
        @data.shift
      end

      def decorate(val)
        return if quiet?(val)

        case val
        when String
          raw? ? val : val.to_json
        when Regexp
          decorate_regexp(val)
        when true, MatchData
          decorate(record)
        else
          val.to_json
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
        # false and nil is special character in JSON
        (val == false && record != false) ||
          (val.nil? && !record.nil?)
      end
    end
  end
end
