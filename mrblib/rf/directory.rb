module Rf
  class Directory
    class Node
      attr_reader :path

      def initialize(path)
        @path = path
        @children = Dir.entries(path).reject { |e| ['.', '..'].include?(e) }.sort
      end

      def next
        return unless child = @children.shift

        File.join(@path, child)
      end
    end

    def initialize(root)
      @nodes = [Node.new(root)]
    end

    def next
      loop do
        path = @nodes.last.next
        unless path
          @nodes.pop
          break if @nodes.empty?

          next
        end

        break path unless File.directory?(path)

        @nodes << Node.new(path)
      end
    end

    def self.open(paths)
      Enumerator.new do |y|
        paths.each do |path|
          if path == '-'
            y << path
            next
          end

          stat = File::Stat.new(path)
          if stat.directory?
            dir = Directory.new(path)
            while path = dir.next
              y << path
            end
          else
            y << path
          end
        end
      end
    end
  end
end
