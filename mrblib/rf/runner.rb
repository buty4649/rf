module Rf
  class Runner # rubocop:disable Metrics/ClassLength
    def self.run(...)
      new(...).run
    end

    attr_reader :config, :bind, :container, :inputs

    %w[
      color? command filter files grep_mode in_place include_filename
      slurp? quiet? recursive? with_record_number?
    ].each do |name|
      n = name.delete_suffix('?')
      define_method(name.to_sym) { config.send(n) }
    end

    # Set 'default' to true for Filter::Text only when multiple files are specified,
    # or when the recursive (-r) option is specified along with a directory.
    def with_filename?
      return true if config.with_filename
      return false if filter != Filter::Text || in_place

      files.size > 1 || (recursive? && File.directory?(files.first))
    end

    # @param [Rf::Config] cfg
    # @param [Boolean] debug
    def initialize(cfg)
      @config = cfg
      @inputs = recursive? ? Directory.open(files, include_filename || filter.filename_extension) : files
      filter.colorize = color?
      setup_container
    end

    # enclose the scope of binding
    def setup_container
      @container = Container.new({
                                   with_filename: with_filename?,
                                   with_record_number: with_record_number?,
                                   colorize: color?
                                 })
      @bind = container.instance_eval { binding }
    end

    def run
      Rf.add_features

      inputs.each do |filename|
        @container.filename = filename
        input = read_open(filename)

        if in_place
          write_file = write_open(filename, in_place)
          $output = write_file
          tempfile = write_file if in_place.empty?
        end

        reader = filter.new(input)
        records = Record.read(reader)
        records = [records.to_a] if slurp?

        records.each_with_index do |record, index|
          index += 1
          result = do_action(record, index, split(record))
          render result, record, reader.binary?
        end
        post_action

        next unless tempfile

        tempfile.close
        input.close
        File.rename(tempfile.path, filename)
      end
    end

    def read_open(file)
      raise IsDirectory, file if File.directory?(file)

      Reader.new(file)
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

    def do_action(record, index, fields)
      container.record = record
      container.fields = fields
      bind.eval("NR = $. = #{index}") # index is Integer

      if grep_mode
        Regexp.new(command)
      else
        bind.eval(command)
      end
    rescue ::SyntaxError => e
      msg = e.message.delete_prefix('file (eval) ')
      raise Rf::SyntaxError, msg
    end

    def render(val, record, binary_match)
      return if quiet?
      return unless output = filter.format(val, record)

      if binary_match
        puts 'Binary file matches.'
      else
        @container.puts output
      end
    end

    def post_action
      container.instance_eval do
        @__at_exit__&.call
      end
    end
  end
end
