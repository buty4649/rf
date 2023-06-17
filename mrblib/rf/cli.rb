module Rf
  class Cli
    attr_reader :config

    def run(argv)
      @config = Config.parse(argv)
      Rf.add_features
      Runner.run({
                   command: config.command,
                   filter: config.filter.new(io),
                   read_all: config.read_all,
                   quiet: config.quiet
                 })
    rescue Files::NotFound => e
      print_exception_and_exit(e, false)
    rescue SyntaxError, StandardError => e
      print_exception_and_exit(e)
    end

    def debug?
      config&.debug
    end

    def io
      if files = config.files
        Files.new(files)
      else
        $stdin
      end
    end

    def print_exception_and_exit(exc, backtrace = debug?)
      if backtrace
        warn "Error: #{exc.inspect}"
        warn
        warn 'trace (most recent call last):'
        exc.backtrace.each_with_index do |line, index|
          i = exc.backtrace.size - index
          warn "  [#{i}] #{line}"
        end
      else
        warn "Error: #{exc}"
      end
      exit 1
    end
  end
end
