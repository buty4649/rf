module Rf
  class Config
    attr_accessor :command, :files, :filter, :slurp, :script_file, :quiet

    def self.parse(argv)
      Parser.new.parse(argv)
    end

    class Parser # rubocop:disable Metrics/ClassLength
      DEFAULT_FILTER_TYPE = :text

      def initialize
        @config = Config.new
      end

      def summary
        OptionParser.new do |opt|
          opt.program_name = 'rf'
          opt.version = VERSION
          opt.release = "mruby #{MRUBY_VERSION}"
          opt.summary_indent = ' ' * 2

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

      def global_options(opt = OptionParser.new)
        opt.separator 'global options:'

        opt.on('-f', '--file=program_file', 'executed the contents of program_file') { |f| @config.script_file = f }
        opt.on('-n', '--quiet', 'suppress automatic priting') { @config.quiet = true }
        opt.on('-s', '--slurp', 'read all reacords into an array') { @config.slurp = true }
        opt.on('--help', 'show this message') { print_help_and_exit }
        opt.on('--version', 'show version') { print_version_and_exit }
      end

      def filter_options(type, opt = global_options)
        opt.separator ''
        opt.separator "#{type} options:"

        case type
        when :text then Filter::Text.configure(opt)
        when :json then Filter::Json.configure(opt)
        when :yaml then Filter::Yaml.configure(opt)
        end
      end

      def all_options
        opt = global_options(summary)
        %i[text json yaml].each do |type|
          filter_options(type, opt)
        end
        opt
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
        @config
      end

      def parse_options(argv)
        print_help_and_exit(1) if argv.empty?

        type, argv = parse_type_option(argv)
        @config.filter = Filter.load(type)

        filter_options(type).order(argv)
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

      def validate_type(arg, type)
        raise "missing argument: #{arg}" unless type
        return if Filter.types.include?(type.to_sym)

        raise %("#{type}" is invalid type. possible values: #{Filter.types.join(',')})
      end

      def print_help_and_exit(exit_status = 0)
        if exit_status.zero?
          puts all_options.help
        else
          warn all_options.help
        end
        exit exit_status
      end

      def print_version_and_exit
        puts all_options.ver
        exit
      end
    end
  end
end
