module Rf
  class Runner
    def self.run(...)
      new(...).run
    end

    attr_reader :config, :container, :bind

    def initialize(config)
      @config = config
      setup_container
    end

    # enclose the scope of binding
    def setup_container
      @container = Container.new
      @bind = container.instance_eval { binding }
    end

    def run
      add_features
      do_action
      post_action
    end

    def add_features
      Rf.add_features_to_integer
      Rf.add_features_to_float
      Rf.add_features_to_hash
    end

    def do_action
      filter.each_record do |record, index, fields|
        container.record = record
        container.NR = index
        container.fields = fields

        ret = bind.eval(command)
        filter.output(ret) unless quiet?
      end
    end

    def post_action
      container.instance_eval do
        @__at_exit__&.call
      end
    end

    def quiet?
      config.quiet
    end

    def command
      config.command
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
  end
end
