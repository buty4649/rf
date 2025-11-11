module Rf
  module Formatter
    class Text < Base
      class << self
        def format(val)
          case val
          when String
            val
          when MatchResult
            matchresult_to_text(val)
          when Array
            val.map(&:to_s).join("\n")
          else
            val.to_s
          end
        end

        def matchresult_to_text(match)
          return match.to_s if match.match_only?

          match.format_string do |s|
            colorize? ? s.red : s
          end
        end
      end
    end
  end
end
