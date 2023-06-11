module Rf
  class Config
    attr_accessor :command, :debug, :files, :filter, :type, :quiet

    def initialize
      @type = :text
    end

    def self.parse(argv)
      Parser.new.parse(argv)
    end

    class Parser
      def initialize
        @config = Config.new
      end

      def option # rubocop:disable Metrics/AbcSize
        @option ||= OptionParser.new do |opt|
          opt.banner = "Usage: rf [options] 'command' file ..."
          opt.summary_indent = ' ' * 2

          opt.on_head('-y', '--yaml', 'equivalent to -tyaml') { @config.type = :yaml }
          opt.on_head('-j', '--json', 'equivalent to -tjson') { @config.type = :json }
          opt.on_head('-t', "--type={#{Filter.types.join('|')}}",
                      "set the type of input (default:#{@config.type})") do |v|
            @config.type = v.to_sym
          end

          opt.on('--debug', 'enable debug mode') { @config.debug = true }
          opt.on('-n', '--quiet', 'suppress automatic priting') { @config.quiet = true }
          opt.on('-h', '--help', 'show this message') { print_help_and_exit }
          opt.on('-v', '--version', 'show version') { print_version_and_exit }

          opt.separator ''
          opt.separator 'text options:'
          opt.on('-F VAL', '--filed-separator', 'set the field separator(regexp)') do |v|
            Filter::Text.config.fs = v
          end

          opt.separator ''
          opt.separator 'json options:'
          opt.on('-r', '--raw-string', 'output raw strings') do
            Filter::Json.config.raw = true
          end
        end
      end

      def parse(argv)
        print_help_and_exit(1) if argv.empty?

        parameter = option.order(argv)
        @config.filter = Filter.load(@config.type)

        print_help_and_exit(1) if parameter.empty?
        @config.command = parameter.shift
        @config.files = parameter unless parameter.empty?

        @config
      end

      def print_help_and_exit(exit_status = 0)
        if exit_status.zero?
          puts option.help
        else
          warn option.help
        end
        exit exit_status
      end

      def print_version_and_exit
        puts Rf::VERSION
        exit
      end
    end
  end
end
