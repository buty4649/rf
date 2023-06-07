module Rf
  class Cli
    attr_reader :config, :container, :bind

    def run(argv)
      setup(argv)
      pre_action
      do_action
      post_action
    rescue Files::NotFound => e
      print_exception_and_exit(e, false)
    rescue SyntaxError, StandardError => e
      print_exception_and_exit(e)
    end

    def setup(argv)
      @config = Config.parse(argv)
      setup_container
    end

    # enclose the scope of binding
    def setup_container
      @container = Container.new
      @bind = container.instance_eval { binding }
    end

    def pre_action
      add_features
    end

    def do_action
      filter.each_record do |record, index, fields|
        container._ = record
        container.NR = $. = index + 1
        $F = fields # rubocop:disable Style/GlobalVars

        ret = bind.eval(command)
        next if config.quiet

        filter.output(ret)
      end
    end

    def post_action
      container.instance_eval do
        @__at_exit__&.call
      end
    end

    def debug?
      config&.debug
    end

    def command
      config.command
    end

    def add_features
      Rf.add_features_to_integer
      Rf.add_features_to_float
      Rf.add_features_to_hash
    end

    def filter
      @filter ||= config.filter.new(io)
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
