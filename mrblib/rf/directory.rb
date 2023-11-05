module Rf
  class Directory
    class Node
      attr_reader :path

      def initialize(path)
        @path = path
        @children = self.open(path)
      end

      def open(path)
        entries = Dir.entries(path).reject do |e|
          %w[. ..].include?(e)
        end
        entries.sort
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

    def self.open(paths, include_filename)
      Enumerator.new do |y|
        paths.each do |path|
          if path == '-' || File.file?(path)
            y << path
          else
            each_entries(path, include_filename) do |entry|
              y << entry
            end
          end
        end
      end
    end

    def self.each_entries(path, include_filename)
      dir = Directory.new(path)
      fnmatch = Regexp.new("\\.#{include_filename}$") if include_filename
      while path = dir.next
        next if fnmatch && !fnmatch.match?(path)

        yield path
      end
    end
  end
end
