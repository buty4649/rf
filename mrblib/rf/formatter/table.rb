module Rf
  module Formatter
    class Table < Base
      class << self
        def format(val)
          case val
          when Hash
            hash_to_table(val)
          when Array
            array_to_table(val)
          else
            raise ArgumentError
          end
        end

        def hash_to_table(hash)
          return '' if hash.empty?

          rows = [hash.keys]

          row_count = max_row_count(hash.values)
          row_count.times do |index|
            r = hash.keys.map do |key|
              v = hash[key]
              if v.is_a?(Array)
                v[index]
              elsif index.zero?
                v
              end
            end

            rows << r
          end

          array_to_table(rows)
        end

        def max_row_count(array)
          array.select { |v| v.is_a?(Array) }.map(&:size).max || 1
        end

        def array_to_table(val)
          return '' if val.empty?

          MarkdownTable.new do |md|
            val.each { |v| md << v }
          end.to_s
        end
      end
    end
  end
end
