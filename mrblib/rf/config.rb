module Rf
  class Config
    class << self
      def current
        @__current
      end

      def from(type, options, argv)
        @__current = new(type, options, argv)
      end
    end

    attr_accessor :expressions
    attr_reader :filter, :files, :formatter

    %w[
      color? include_filename ignore_case in_place recursive? invert_match?
      script_file slurp? quiet? with_filename? with_record_number?
    ].each do |name|
      s = name.delete_suffix('?').to_sym
      define_method(name.to_sym) do
        self[s]
      end
    end

    def initialize(type, options, argv)
      @type = type
      t = @type == :grep ? :text : @type

      @filter = Filter.load(t)
      @formatter = Formatter.load(t)
      @options = options
      @argv = argv.dup
      setup_expressions

      @options[:color] = false if @options[:in_place]
      @files = @argv.empty? ? %w[-] : @argv

      validate
    end

    def [](key)
      @options[key.to_sym]
    end

    def has?(key)
      @options.key?(key.to_sym)
    end

    def validate
      raise Rf::ConflictOptions, %i[-R -i] if has?(:in_place) && has?(:recursive)
    end

    private

    def setup_expressions
      if script_file
        @expressions = [File.read(script_file)]
        return
      end

      expr = @options[:expression]

      if expr
        @expressions = expr
      elsif @argv.any?
        @expressions = [@argv.shift]
      else
        raise NoExpression
      end

      return unless @type == :grep

      opt = @options[:ignore_case] ? Regexp::IGNORECASE : nil
      @expressions = [Regexp.new(@expressions.join('|'), opt)]
    end
  end
end
