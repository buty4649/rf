module Rf
  class Runner
    def self.run(...)
      new(...).run
    end

    attr_reader :container, :bind,
                :quiet, :command,
                :filter
    alias quiet? quiet

    # @param [Hash<String>] opts
    #   :command => String
    #   :filter => Rf::Filter
    #   :quiet => Boolean
    def initialize(opts)
      @command = opts[:command]
      @filter = opts[:filter]
      @quiet = opts[:quiet]

      setup_container
    end

    # enclose the scope of binding
    def setup_container
      @container = Container.new
      @bind = container.instance_eval { binding }
    end

    def run
      do_action
      post_action
    end

    def do_action
      filter.each_record do |record, index, fields|
        container.record = record
        container.fields = fields
        bind.eval("NR = $. = #{index}") # index is Integer

        render bind.eval(command)
      end
    end

    def render(val)
      return if quiet?(val)
      return unless s = filter.decorate(val)

      puts s
    end

    def post_action
      container.instance_eval do
        @__at_exit__&.call
      end
    end
  end
end
