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

    attr_reader :expressions, :filter, :files, :formatter
    attr_accessor :grep_mode

    %w[
      color? include_filename in_place recursive? invert_match?
      script_file slurp? quiet? with_filename? with_record_number?
    ].each do |name|
      s = name.delete_suffix('?').to_sym
      define_method(name.to_sym) do
        self[s]
      end
    end

    def initialize(type, options, argv)
      @filter = Filter.load(type)
      @formatter = Formatter.load(type)
      @options = options
      @expressions = options[:expression] || []

      validate

      argv = argv.dup

      @expressions << File.read(script_file) if script_file
      @expressions << argv.shift if @expressions.empty? && argv.any?

      raise NoExpression if @expressions.empty?

      @files = argv
      @files << '-' if @files.empty?
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
  end
end
