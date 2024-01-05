module Rf
  class Config
    attr_accessor :color, :command, :files, :filter, :grep_mode, :include_filename, :in_place,
                  :slurp, :script_file, :quiet, :recursive, :with_filename, :with_record_number

    def self.parse(argv)
      Parser.new.parse(argv)
    end

    class Parser # rubocop:disable Metrics/ClassLength
      DEFAULT_FILTER_TYPE = :text

      class OptionMap
        attr_reader :opts

        def initialize
          @opts = []

          yield self if block_given?
        end

        def on(*args, &block)
          @opts << {
            args:,
            block:
          }
        end

        # Transfer options to OptionParser
        # @param parser [OptionParser]
        # @return [OptionParser]
        def transfer(parser)
          @opts.each do |opt|
            parser.on(*opt[:args], &opt[:block])
          end

          parser
        end
      end

      def initialize
        @config = default_config
        @filter_options = load_filter_options
      end

      def default_config
        Config.new.tap do |cfg|
          cfg.color = $stdout.tty?
          cfg.files = %w[-]
        end
      end

      def load_filter_options
        result = {}

        Filter.types.each do |type|
          opt = OptionMap.new
          Filter.load(type).configure(opt)
          result[type] = opt
        end

        result
      end

      def help_text
        opts = banner_and_filter_options
        opts.separator 'global options:'
        global_options.transfer(opts)
        opts.separator ''
        opts.help + summarize_filter_options
      end

      def option_parser
        OptionParser.new do |opt|
          opt.program_name = 'rf'
          opt.version = VERSION
          opt.release = mruby_version
          opt.summary_indent = ' ' * 2
        end
      end

      def mruby_version
        "mruby #{MRUBY_VERSION} #{MRUBY_COMMIT_ID[0..6]}"
      end

      def banner_and_filter_options
        option_parser.tap do |opt|
          opt.banner = <<~BANNER
            Usage: rf [filter type] [options] 'command' file ...
                   rf [filter type] [options] -f program_file file ...
          BANNER
          opt.separator 'filter types:'
          opt.on('-t', "--type={#{Filter.types.join('|')}}", 'set the type of input (default: text)')
          opt.on('-j', '--json', 'same as --type=json')
          opt.on('-y', '--yaml', 'same as --type=yaml')
          opt.separator ''
        end
      end

      def global_options # rubocop:disable Metrics/AbcSize
        @global_options ||= OptionMap.new do |opt|
          opt.on('-H', '--with-filename', 'print filename with output lines') { @config.with_filename = true }
          opt.on('--with-record-number', 'print record number with output lines') do
            @config.with_record_number = true
          end
          opt.on('-R', '--recursive', 'read all files under each directory recursively') { @config.recursive = true }
          opt.on('--include-filename', 'searches for files matching a regex pattern') do |p|
            @config.include_filename = p
          end
          opt.on('-f', '--file=program_file', 'executed the contents of program_file') { |f| @config.script_file = f }
          opt.on('-g', '--grep', 'Interpret command as a regex pattern for searching (like grep)') do
            @config.grep_mode = true
          end
          opt.on('-i[SUFFIX]', '--in-place[=SUFFIX]', 'edit files in place (makes backup if SUFFIX supplied)') do |v|
            @config.in_place = v || ''
          end
          opt.on('-n', '--quiet', 'suppress automatic printing') { @config.quiet = true }
          opt.on('-s', '--slurp', 'read all reacords into an array') { @config.slurp = true }
          opt.on('--[no-]color', '[no] colorized output (default: --color in TTY)') do |v|
            @config.color = v
          end
          opt.on('--help', 'show this message') { print_help_and_exit }
          opt.on('--version', 'show version') { print_version_and_exit }
        end
      end

      def summarize_filter_options
        Filter.types.map do |type|
          OptionParser.new do |opt|
            opt.summary_indent = ' ' * 2
            opt.separator "#{type} options:"
            Filter.load(type).configure(opt)
          end.summarize.join
        end.join("\n")
      end

      def parse(argv)
        parameter = parse_options(argv)

        if @config.script_file
          @config.command = File.read(@config.script_file)
        else
          print_help_and_exit(1) if parameter.empty?
          @config.command = parameter.shift
        end
        @config.files = parameter unless parameter.empty?

        validate_config

        @config
      end

      def parse_options(argv)
        print_help_and_exit(1) if argv.empty?

        type, argv = parse_type_option(argv)
        @config.filter = Filter.load(type)

        @filter_options[type].transfer(
          global_options.transfer(option_parser)
        ).order(argv)
      end

      def parse_type_option(argv)
        argv = argv.dup
        type = case argv.first
               when '-t', '--type'
                 arg, type = argv.shift(2)
                 validate_type(arg, type)
                 type.to_sym
               when /^(-t)(.+)$/, /^(--type)=(.+)$/
                 argv.shift
                 arg = Regexp.last_match[1]
                 type = Regexp.last_match[2]
                 validate_type(arg, type)
                 type.to_sym
               when '-j', '--json'
                 argv.shift
                 :json
               when '-y', '--yaml'
                 argv.shift
                 :yaml
               else
                 DEFAULT_FILTER_TYPE
               end
        [type, argv]
      end

      def print_help_and_exit(exit_status = 0)
        if exit_status.zero?
          puts help_text
        else
          warn help_text
        end
        exit exit_status
      end

      def print_version_and_exit
        puts option_parser.ver
        exit
      end

      def validate_type(arg, type)
        raise "missing argument: #{arg}" unless type
        return if Filter.types.include?(type.to_sym)

        raise %("#{type}" is invalid type. possible values: #{Filter.types.join(',')})
      end

      def validate_config
        raise ConflictOptions, %w[-R -i] if @config.recursive && @config.in_place
      end
    end
  end
end
