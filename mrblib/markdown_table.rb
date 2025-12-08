class MarkdownTable
  def initialize
    @row = []
    @col_width = 0
    @col_count = 0

    return unless block_given?

    yield self
  end

  def <<(val)
    r = if val.is_a?(Array)
          val
        else
          [val]
        end
    @col_count = [@col_count, r.size].max
    @row << r.map do |v|
      s = v.to_s
      @col_width = [@col_width, s.length].max
      s
    end

    self
  end

  def to_s
    return if @row.empty?

    result = [array_to_row(@row.first)]
    result << separator

    result += @row[1..].map { |r| array_to_row(r) }

    result.join("\n")
  end

  def array_to_row(ary)
    cols = ary.map { |a| a.ljust(@col_width) }
    cols += [' ' * @col_width] * (@col_count - cols.size) if @col_count > cols.size

    format('| %s |', cols.join(' | '))
  end

  def separator
    format('|%s|', (['-' * (@col_width + 2)] * @col_count).join('|'))
  end
end
