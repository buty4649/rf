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
      coordinator.each do |input, _index|
        container.input = input
        ret = bind.eval(command)

        ret = ret.match?(input) if ret.instance_of?(Regexp)
        next if quiet?(ret)

        coordinator.puts(if all_print?(ret)
                           input
                         else
                           ret
                         end)
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
      @config.command
    end

    def quiet?(val)
      @config.quiet || val.nil? || val == false || !valid_instance_of?(val)
    end

    def valid_instance_of?(val)
      val.instance_of?(TrueClass) ||
        val.instance_of?(String) ||
        val.instance_of?(Integer) ||
        val.instance_of?(Float) ||
        val.instance_of?(Array) ||
        val.instance_of?(Hash) ||
        val.instance_of?(MatchData)
    end

    def add_features
      Rf.add_features_to_integer
      Rf.add_features_to_float
      Rf.add_features_to_hash
    end

    def coordinator
      @coordinator ||= @config.filter.new(io)
    end

    def io
      if files = @config.files
        Files.new(files)
      else
        $stdin
      end
    end

    def all_print?(val)
      val == true
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
