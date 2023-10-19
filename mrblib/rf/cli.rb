module Rf
  class Cli
    attr_reader :config

    def run(argv)
      @config = Config.parse(argv)
      Rf.add_features
      Runner.run({
                   command: config.command,
                   filter: config.filter.new(io),
                   slurp: config.slurp,
                   quiet: config.quiet
                 })
    rescue NotFound => e
      print_exception_and_exit(e, false)
    rescue StandardError => e
      print_exception_and_exit(e)
    end

    def debug?
      ENV.fetch('RF_DEBUG', nil)
    end

    def io
      StreamIO.new(config.files)
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
