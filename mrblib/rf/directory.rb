module Rf
  class Directory
    class Node
      attr_reader :path

      def initialize(path)
        @path = path
        @dir = Dir.open(path)
      end

      def next
        child = loop do
          child = @dir.read
          return unless child
          break child unless %w[. ..].include?(child)
        end

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
