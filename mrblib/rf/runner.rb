module Rf
  class Runner
    def self.run(...)
      new(...).run
    end

    attr_reader :container, :bind,
                :command, :filter

    # @param [Hash<String>] opts
    #   :command => String
    #   :filter => Rf::Filter
    #   :slurp => Boolean
    #   :quiet => Boolean
    def initialize(opts)
      @command = opts[:command]
      @filter = opts[:filter]
      @slurp = true & opts[:slurp]
      @quiet = true & opts[:quiet]

      setup_container
    end

    def slurp?
      @slurp
    end

    def quiet?
      @quiet
    end

    # enclose the scope of binding
    def setup_container
      @container = Container.new
      @bind = container.instance_eval { binding }
    end

    def run
      records = filter.records
      if slurp?
        r = records.to_a
        do_action(r, 1, r)
      else
        records.each_with_index do |record, index|
          index += 1
          do_action(record, index, filter.split(record))
        end
      end
      post_action
    end

    def do_action(record, index, fields)
      container.record = record
      container.fields = fields
      bind.eval("NR = $. = #{index}") # index is Integer

      render bind.eval(command), record
    end

    def records
      Enumerator.new do |y|
        while record = filter.gets
          y << [record, filter.index, filter.split(record)]
        end
      end
    end

    def render(val, record)
      return if quiet?
      return unless output = filter.format(val, record)

      puts output
    end

    def post_action
      container.instance_eval do
        @__at_exit__&.call
      end
    end
  end
end
