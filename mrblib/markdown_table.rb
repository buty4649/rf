class MarkdownTable
  def initialize
    @row = []
    @widths = []
    @count = 0

    return unless block_given?

    yield self
  end

  def <<(val)
    r = if val.is_a?(Array)
          val
        else
          [val]
        end
    @count = [@count, r.size].max
    @row << r.map.with_index do |v, idx|
      s = v.to_s
      @widths[idx] = [@widths[idx] || 0, s.length].max
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
    cols = ary.map.with_index do |a, idx|
      a.ljust(@widths[idx])
    end

    if @count > cols.size
      cols += (@count - cols.size).times.map do |offset|
        ' ' * @widths[cols.size + offset]
      end
    end

    format('| %s |', cols.join(' | '))
  end

  def separator
    cols = @count.times.map do |idx|
      '-' * (@widths[idx] + 2)
    end

    "|#{cols.join('|')}|"
  end
end
