$output = $stdout

module Rf
  class Container
    attr_accessor :filename

    def initialize(opts = {})
      @filenem = opts[:filename]
      @with_filename = opts[:with_filename] || false
      @with_record_number = opts[:with_record_number] || false
      @colorize = opts[:colorize] || false
    end

    def _
      $_
    end

    def _=(data)
      $_ = data
    end

    alias record _
    alias record= _=

    def fields
      $F
    end

    def fields=(data)
      $F = data
    end

    def string?
      _.instance_of?(String)
    end

    def hash?
      _.instance_of?(Hash)
    end

    def puts(*)
      $output.write(generate_line_prefix)
      $output.puts(*)
    end

    def generate_line_prefix
      prefix = []
      prefix << filename if @with_filename && filename
      prefix << NR.to_s if @with_record_number
      prefix.map do |s|
        if @colorize
          s.magenta + ':'.cyan
        else
          "#{s}:"
        end
      end.join
    end

    %i[gsub gsub! sub sub! tr tr!].each do |sym|
      define_method(sym) do |*args, &block|
        _.__send__(sym, *args, &block) if string?
      end
    end

    def match(condition)
      regexp = if condition.is_a?(Regexp)
                 condition
               elsif condition.is_a?(String)
                 Regexp.new(condition)
               elsif true & condition
                 /^.*$/
               end
      ret = regexp&.match(_.to_s)

      return ret unless ret && block_given?

      yield(*fields)
    end
    alias m match

    def match?(condition)
      match(condition) ? true : false
    end
    alias m? match?

    %i[dig].each do |sym|
      define_method(sym) do |*args|
        _.__send__(sym, *args) if hash?
      end
    end

    def respond_to_missing?(sym, *)
      # check for _0, _1, _2, _3, ...
      sym.to_s =~ /\A_(0|[1-9]\d*)\z/ || super
    end

    def method_missing(sym, *)
      s = sym.to_s
      # check for _0, _1, _2, _3, ...
      if sym == :_0
        _
      elsif s =~ /\A_[1-9]\d*\z/
        $F[s[1..].to_i - 1]
      else
        super
      end
    end

    def at_exit(&block)
      @__at_exit__ ||= block
    end
  end
end
