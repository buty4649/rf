module Rf
  class Cli < Magni # rubocop:disable Metrics/ClassLength
    app_name 'rf'
    default_command :text

    class_option :color, type: :boolean, default: $stdout.tty?,
                         desc: '[no] colorized output (default: --color in TTY)'
    class_option :expression, type: :string, display_name: 'e', banner: "'code'", repeatable: true,
                              desc: 'evaluate the expression (can be specified multiple times)'
    class_option :include_filename, banner: 'pattern', desc: 'searches for files matching a regex pattern'
    class_option :quiet, type: :flag, aliases: :q,
                         desc: 'suppress automatic printing'
    class_option :recursive, type: :flag, aliases: :R,
                             desc: 'read all files under each directory recursively'
    class_option :with_filename, type: :flag, aliases: :H,
                                 desc: 'print filename with output lines'
    class_option :with_record_number, type: :flag,
                                      desc: 'print record number with output lines'

    option :in_place, type: :string, aliases: :i, banner: '[=SUFFIX]',
                      desc: 'edit files in place (makes backup if SUFFIX supplied)'
    option :script_file, type: :string, aliases: :f, display_name: 'file',
                         desc: 'executed the contents of program_file'
    option :slurp, type: :flag, aliases: :s, desc: 'read all reacords into an array'
    option :filed_separator, aliases: :F
    desc 'text', 'use Text filter'
    order 0
    def text(*argv)
      run :text, argv
    end

    option :invert_match, type: :flag, aliases: :v, desc: 'select non-matching records'
    desc 'grep', 'use Text filter with grep mode'
    order 1
    def grep(*argv)
      run :grep, argv
    end

    option :in_place, type: :string, aliases: :i, banner: '[=SUFFIX]',
                      desc: 'edit files in place (makes backup if SUFFIX supplied)'
    option :script_file, type: :string, aliases: :f, display_name: 'file',
                         desc: 'executed the contents of program_file'
    option :slurp, type: :flag, aliases: :s, desc: 'read all reacords into an array'
    option :raw?, aliases: :r, display_name: 'raw-output', type: :flag,
                  desc: 'output raw strings without JSON encoding'
    option :minify?, display_name: 'minify', type: :flag,
                     desc: 'output compact JSON without pretty printing'
    desc 'json', 'use JSON filter'
    order 2
    def json(*argv)
      run :json, argv
    end

    option :in_place, type: :string, aliases: :i, banner: '[=SUFFIX]',
                      desc: 'edit files in place (makes backup if SUFFIX supplied)'
    option :script_file, type: :string, aliases: :f, display_name: 'file',
                         desc: 'executed the contents of program_file'
    option :slurp, type: :flag, aliases: :s, desc: 'read all reacords into an array'
    option :raw?, aliases: :r, display_name: 'raw-output', type: :flag,
                  desc: 'output raw strings without YAML encoding'
    option :doc?, display_name: 'doc', type: :boolean,
                  desc: '[no] include YAML document header (---)'
    desc 'yaml', 'use YAML filter'
    order 3
    def yaml(*argv)
      run :yaml, argv
    end

    desc 'version', 'show version'
    order 90
    def version
      print_version_and_exit
    end

    class << self
      def usage(name, command)
        if command == 'grep'
          "#{name} grep [options] pattern [file ...]"
        else
          c = command || '[command]'
          <<~USAGE
            #{name} #{c} [options] 'code' [file ...]
            #{name} #{c} [options] -f program_file [file ...]
          USAGE
        end
      end

      def show_help_on_failure? = false
    end

    no_commands do # rubocop:disable Metrics/BlockLength
      def run(type, argv)
        t = type == :grep ? :text : type
        config = Config.from(t, options, argv)

        config.expressions = [Regexp.new(config.expressions.join('|'))] if type == :grep

        Runner.run(config)
      rescue Rf::NoExpression
        help
      rescue Rf::Error => e
        print_exception_and_exit(e, false)
      rescue StandardError => e
        print_exception_and_exit(e)
      end

      def print_version_and_exit
        puts "rf #{Rf::VERSION} (mruby #{MRUBY_VERSION} #{MRUBY_COMMIT_ID[0..6]})"
        exit
      end

      def debug?
        ENV.fetch('RF_DEBUG', nil)
      end

      def print_exception_and_exit(exc, backtrace = debug?)
        if backtrace
          warn "Error: #{exc.inspect}"
          warn
          warn 'trace (most recent call last):'
          exc.backtrace.each_with_index do |line, index|
            i = exc.backtrace.size - index
            warn "  [#{i}] #{line}"
          end
        else
          warn "Error: #{exc}"
        end
        exit 1
      end
    end
  end
end
