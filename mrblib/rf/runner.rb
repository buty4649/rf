module Rf
  class Runner # rubocop:disable Metrics/ClassLength
    def self.run(...)
      new(...).run
    end

    attr_reader :config, :bind, :container, :inputs

    %w[
      command filter files grep_mode in_place include_filename
      slurp? quiet? recursive?
    ].each do |name|
      n = name.delete_suffix('?')
      define_method(name.to_sym) { config.send(n) }
    end

    # Set 'default' to true for Filter::Text only when multiple files are specified,
    # or when the recursive (-r) option is specified along with a directory.
    def with_filename?
      return true if config.with_filename
      return false unless filter == Filter::Text

      files.size > 1 || (recursive? && File.directory?(files.first))
    end

    # @param [Rf::Config] cfg
    # @param [Boolean] debug
    def initialize(cfg)
      @config = cfg
      @inputs = recursive? ? Directory.open(files, include_filename || filter.filename_extension) : files

      setup_container
    end

    # enclose the scope of binding
    def setup_container
      @container = Container.new
      @bind = container.instance_eval { binding }
      @container.with_filename = with_filename?
    end

    def run # rubocop:disable Metrics/AbcSize
      Rf.add_features

      inputs.each do |filename|
        @container.filename = filename
        input = read_open(filename)

        if in_place
          write_file = write_open(filename, in_place)
          $output = write_file
          tempfile = write_file if in_place.empty?
        end

        records = Record.read(filter.new(input))
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

        next unless tempfile

        tempfile.close
        input.close
        File.rename(tempfile.path, filename)
      end
    end

    def read_open(file)
      return $stdin if file == '-'
      raise IsDirectory, file if File.directory?(file)

      File.open(file)
    rescue Errno::ENOENT
      raise NotFound, file
    rescue Errno::EACCES
      raise PermissionDenied, file
    end

    def write_open(file, in_place)
      if in_place.empty?
        dir = File.dirname(file)
        Tempfile.new('.rf', dir)
      else
        raise NotFound, file unless File.exist?(file)
        raise NotRegularFile, file unless File.file?(file)

        File.open("#{file}#{in_place}", 'w')
      end
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

    def do_action(record, index, fields) # rubocop:disable Metrics/AbcSize
      container.record = record
      container.fields = fields
      bind.eval("NR = $. = #{index}") # index is Integer

      result = if grep_mode
                 Regexp.new(command)
               else
                 bind.eval(command)
               end
      render result, record
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
