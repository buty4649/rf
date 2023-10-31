module Rf
  class Runner
    def self.run(...)
      new(...).run
    end

    attr_reader :container, :bind, :command, :filter, :files, :with_filename

    # @param [Hash<String>] opts
    #   :command => String
    #   :files => Array<String>
    #   :filter => Rf::Filter
    #   :slurp => Boolean
    #   :quiet => Boolean
    #   :with_filename => Boolean
    def initialize(opts)
      @command = opts[:command]
      @files = opts[:files] || %w[-]
      @filter = opts[:filter]
      @slurp = true & opts[:slurp]
      @quiet = true & opts[:quiet]

      setup_container
      @container.with_filename = opts[:with_filename] || (files.size > 1 && filter == Filter::Text)
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

    def run # rubocop:disable Metrics/AbcSize
      Rf.add_features

      files.each do |filename|
        @container.filename = filename
        records = Record.read(filter.new(self.open(filename)))
        if slurp?
          r = records.to_a
          do_action(r, 1, r)
        else
          records.each_with_index do |record, index|
            index += 1
            do_action(record, index, split(record))
          end
        end
        post_action
      end
    end

    def open(file)
      return $stdin if file == '-'

      stat = File::Stat.new(file)
      raise IsDirectory, file if stat.directory?

      File.open(file)
    rescue Errno::ENOENT
      raise NotFound, file
    end

    def split(val)
      case val
      when Array
        val
      when Hash
        val.to_a
      when String
        val.split
      else
        [val]
      end
    end

    def do_action(record, index, fields)
      container.record = record
      container.fields = fields
      bind.eval("NR = $. = #{index}") # index is Integer

      render bind.eval(command), record
    rescue ::SyntaxError => e
      msg = e.message.delete_prefix('file (eval) ')
      raise Rf::SyntaxError, msg
    end

    def render(val, record)
      return if quiet?
      return unless output = filter.format(val, record)

      @container.puts output
    end

    def post_action
      container.instance_eval do
        @__at_exit__&.call
      end
    end
  end
end
