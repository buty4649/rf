module Rf
  class Config
    attr_accessor :command, :debug, :files, :filter, :slurp, :script_file, :quiet

    def self.parse(argv)
      Parser.new.parse(argv)
    end

    class Parser
      DEFAULT_FILTER_TYPE = :text

      def initialize
        @config = Config.new
      end

      def option # rubocop:disable Metrics/AbcSize
        @option ||= OptionParser.new do |opt|
          opt.program_name = 'rf'
          opt.version = VERSION
          opt.release = "mruby #{MRUBY_VERSION}"
          opt.summary_indent = ' ' * 2

          opt.banner = <<~BANNER
            Usage: rf [options] 'command' file ...
                   rf [options] -f program_file file ...
          BANNER

          opt.separator 'global options:'
          opt.on('-t', "--type={#{Filter.types.join('|')}}",
                 "set the type of input (default: #{DEFAULT_FILTER_TYPE})") do |v|
            load_filter(v.to_sym)
          end
          opt.on('-j', '--json', 'same as -tjson') { load_filter(:json) }
          opt.on('-y', '--yaml', 'same as -tyaml') { load_filter(:yaml) }

          opt.on('-f', '--file=program_file', 'executed the contents of program_file') { |f| @config.script_file = f }
          opt.on('-n', '--quiet', 'suppress automatic priting') { @config.quiet = true }
          opt.on('-s', '--slurp', 'read all reacords into an array') { @config.slurp = true }
          opt.on('--debug', 'enable debug mode') { @config.debug = true }
          opt.on('--help', 'show this message') { print_help_and_exit }
          opt.on('--version', 'show version') { print_version_and_exit(opt) }

          add_text_options(opt)
          add_json_options(opt)
          add_yaml_options(opt)
        end
      end

      def add_text_options(opt)
        opt.separator ''
        opt.separator 'text options:'
        opt.on('-F VAL', '--filed-separator', 'set the field separator(regexp)') do |v|
          Filter::Text.config.fs = v
        end
      end

      def add_json_options(opt)
        opt.separator ''
        opt.separator 'json options:'
        opt.on('-r', '--raw-string', 'output raw strings') do
          Filter::Json.config.raw = true
        end
      end

      def add_yaml_options(opt)
        opt.separator ''
        opt.separator 'yaml options:'
        opt.on('--[no-]doc', '[no] output document sperator(---) (default:--no-doc)') do |v|
          Filter::Yaml.config.no_doc = !v
        end
      end

      def parse(argv)
        parameter = parse_options(argv)
        load_filter(DEFAULT_FILTER_TYPE) unless @config.filter

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
        option.order(argv)
      end

      def load_filter(type)
        @config.filter = Filter.load(type)
      end

      def print_help_and_exit(exit_status = 0)
        if exit_status.zero?
          puts option.help
        else
          warn option.help
        end
        exit exit_status
      end

      def print_version_and_exit(opt)
        puts opt.ver
        exit
      end
    end
  end
end
