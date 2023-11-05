module Rf
  class Runner
    def self.run(...)
      new(...).run
    end

    attr_reader :container, :bind, :command, :filter, :inputs, :with_filename

    # @param [Hash<String>] opts
    #   :command => String
    #   :files => Array<String>
    #   :filter => Rf::Filter
    #   :inlude_filename => String or nil
    #   :slurp => Boolean
    #   :recursive => Boolean
    #   :quiet => Boolean
    #   :with_filename => Boolean
    def initialize(opts) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
      @command = opts[:command]
      @filter = opts[:filter]
      @slurp = opts[:slurp]
      @quiet = opts[:quiet]

      files = opts[:files] || %w[-]
      recursive = opts[:recursive]
      include_filename = opts[:inlude_filename] || filter.filename_extension
      @inputs = recursive ? Directory.open(files, include_filename) : files

      with_filename = opts[:with_filename]
      with_filename ||= filter == Filter::Text && (
        files.size > 1 || (recursive && File.directory?(files.first))
      )

      setup_container(with_filename)
    end

    def slurp?
      @slurp
    end

    def quiet?
      @quiet
    end

    # enclose the scope of binding
    def setup_container(with_filename)
      @container = Container.new
      @bind = container.instance_eval { binding }
      @container.with_filename = with_filename
    end

    def run # rubocop:disable Metrics/AbcSize
      Rf.add_features

      inputs.each do |filename|
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
    rescue Errno::EACCES
      raise PermissionDenied, file
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
