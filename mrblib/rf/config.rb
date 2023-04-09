module Rf
  class Config
    attr_accessor :command, :debug, :files, :type, :quiet, :text_fs

    def initialize
      @type = 'text'
    end

    def self.parse(argv)
      Parser.new.parse(argv)
    end

    class Parser
      def initialize
        @config = Config.new
        @opt = OptionParser.new
        setup
      end

      def setup # rubocop:disable Metrics/AbcSize
        @opt.banner = "Usage: rf [options] 'command' file ..."

        @opt.on_head('-y', '--yaml', 'equivalent to -tyaml') { @config.type = 'yaml' }
        @opt.on_head('-j', '--json', 'equivalent to -tjson') { @config.type = 'json' }
        @opt.on_head('-t VAL', '--type', 'select the type of input data from text/json/yaml (default: text)') do |v|
          @config.type = v
        end

        @opt.on('--debug', 'enable debug mode') { @config.debug = true }
        @opt.on('-n', '--quiet', 'suppress automatic priting') { @config.quiet = true }

        # type:text
        @opt.on('-F VAL', '--filed-separator', '(type:text) set the field separator(regexp)') do |v|
          @config.text_fs = v
        end

        @opt.on_tail('-h', '--help', 'show this message') { print_help_and_exit }
        @opt.on_tail('-v', '--version', 'show version') { print_version_and_exit }
      end

      def parse(argv)
        print_help_and_exit if argv.empty?

        parameter = @opt.parse(argv)
        print_help_and_exit if parameter.empty?
        @config.command = parameter.shift
        @config.files = parameter unless parameter.empty?

        @config
      end

      def print_help_and_exit
        warn @opt.help
        exit 1
      end

      def print_version_and_exit
        warn Rf::VERSION
        exit
      end
    end
  end
end
