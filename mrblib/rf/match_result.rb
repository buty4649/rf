module Rf
  class MatchResult
    attr_reader :record, :match_data

    def initialize(record, match_data, match_only)
      @record = record
      @match_data = match_data
      @match_only = match_only
    end

    def match_only?
      @match_only
    end

    def format_string
      raise ArgumentError, 'block not given' unless block_given?

      result = @match_data.each_with_object('') do |m, memo|
        memo << m.pre_match
        memo << yield(m.to_s)
      end
      result + @match_data.last.post_match
    end

    def to_s
      @match_data.map do |m|
        m.size == 1 ? m[0] : m[1..]
      end.flatten.join(' ')
    end

    class << self
      def from_match_data(record, match_data)
        new(record, [match_data], true)
      end

      def from_regexp(record, regexp)
        match_data = []
        s = record.to_s
        while m = regexp.match(s)
          match_data << m
          s = m.post_match
        end
        new(record, match_data, false) if match_data.any?
      end
    end
  end
end
