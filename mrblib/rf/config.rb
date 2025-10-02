module Rf
  class Config
    attr_reader :command, :filter, :files

    %w[
      color? grep_mode include_filename in_place recursive? script_file slurp?
      quiet? with_filename? with_record_number?
    ].each do |name|
      s = name.delete_suffix('?').to_sym
      define_method(name.to_sym) do
        self[s]
      end
    end

    def initialize(type, options, argv)
      @filter = Filter.load(type)
      @options = options

      validate

      argv = argv.dup
      raise ArgumentError if argv.empty? && script_file.nil?

      @command = if script_file
                   File.read(script_file)
                 else
                   argv.shift
                 end

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
