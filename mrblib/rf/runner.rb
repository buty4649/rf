module Rf
  class Runner # rubocop:disable Metrics/ClassLength
    def self.run(...)
      new(...).run
    end

    attr_reader :config, :bind, :container, :inputs

    %w[
      color? expressions filter files formatter grep_mode in_place include_filename
      invert_match? slurp? quiet? recursive? with_record_number?
    ].each do |name|
      sym = name.to_sym
      define_method(sym) { config.send(sym) }
    end

    # Set 'default' to true for Filter::Text only when multiple files are specified,
    # or when the recursive (-r) option is specified along with a directory.
    def with_filename?
      return true if config.with_filename?
      return false if filter != Filter::Text || in_place

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

        records = filter.new(input)
        records = [records.to_a] if slurp?

        binary_match = apply_expressions(records)
        warn_binary_match(filename) if binary_match

        next unless tempfile

        tempfile.close
        input.close
        File.rename(tempfile.path, filename)
      end
    end

    def read_open(file)
      raise IsDirectory, file if File.directory?(file)

      if file == '-'
        $stdin
      else
        File.open(file, 'r')
      end
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

    def apply_expressions(records)
      indexes = [0] * expressions.size
      binary_match = false

      records.each do |record|
        _, result = expressions.each_with_object([0, record]) do |expr, memo|
          index, record = memo

          next unless record

          record = record.record if record.is_a?(MatchResult)
          i = indexes[index] += 1

          result = do_action(record, i, expr)
          result = filter_result(result, record)

          memo[0] += 1
          memo[1] = result
        end

        binary_match = render(result) || binary_match if result
      end

      post_action

      binary_match
    end

    def do_action(record, index, expr)
      container.record = record
      container.fields = split(record)
      bind.eval("NR = $. = #{index}") # index is Integer

      if grep_mode
        Regexp.new(expr)
      else
        bind.eval(expr)
      end
    rescue ::SyntaxError => e
      msg = e.message.delete_prefix('file (eval) ')
      raise Rf::SyntaxError, msg
    end

    def filter_result(result, record)
      case result
      when Regexp
        result = MatchResult.from_regexp(record, result)
        if invert_match?
          record if result.nil?
        else
          result
        end
      when MatchData
        MatchResult.from_match_data(record, result)
      when true
        record
      else
        result
      end
    end

    def render(val)
      return if quiet?

      output = if val.is_a?(FormattedString)
                 val
               else
                 formatter.format(val)
               end
      return unless output

      binary_match = binary?(output)
      @container.puts output unless binary_match

      binary_match
    end

    def binary?(str)
      !!str.index("\x00") || !str.force_encoding('UTF-8').valid_encoding?
    end

    def post_action
      container.instance_eval do
        @__at_exit__&.call
      end
    end

    def warn_binary_match(filename)
      f = filename == '-' ? '(stdin)' : filename

      warn "Warning: #{f}: binary file matches" unless quiet?
    end
  end
end
