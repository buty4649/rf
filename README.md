[English](./README.md) | [日本語(Japanese)](./README_ja.md)

---

# rf

rf is a CLI tool that filters text/JSON/YAML with Ruby code.
These files are processed using tools such as [awk](https://www.gnu.org/software/gawk/manual/gawk.html), [jq](https://jqlang.github.io/jq/), and [yq](https://github.com/mikefarah/yq), each of which requires you to learn how to use them and their syntax.
With rf, you can write equivalent processing in Ruby code, making it a tool that Rubyists can easily use.

rf is built using [mruby](https://github.com/mruby/mruby) and consists of a single binary file.
You don't need to install Ruby separately to use rf.
One of the features of rf is that you can start using it immediately by downloading the binary file.

## Quick Start Guide

Replace part of the text

```sh
rf 'gsub(/hello/, "world")' example.txt
```

Read from standard input

```sh
rf 'gsub(/hello/, "world")' < example.txt
```

Display only lines that contain specific patterns

```sh
rf '/hello/' example.txt
```

UTF-8 can also be used for specified patterns

```sh
rf '/🍣/' example.txt
```

Add the second column of comma-separated files

```sh
rf -F, 's||=0;s+=_2; at_exit{putts s}' example.csv
```

Output a specific key in a JSON file

```sh
rf -j '.a.b' example.json
```

Output a specific key in a YAML file

```sh
rf -y '.a.b' example.json
```

## Installation

You can download rf from the [Release page](https://github.com/buty4649/rf/releases).
Binary files are provided for each platform and architecture.
Please refer to the following table for each corresponding status.

|     | amd64 | arm64|
|-----|-------|------|
|Linux|✅    |✅    |
|MacOS|✅    |✅    |
|Windows|✅  |-     |

You can also install it using each package manager as another method.

### [asdf](https://asdf-vm.com/)

```sh
asdf plugin install rf https://github.com/buty4649/asdf-rf/
asdf install rf latest
asdf global rf latest
```

### [rtx](https://github.com/jdxcode/rtx)

```sh
rtx plugin install rf https://github.com/buty4649/asdf-rf/
rtx install rf@latest
rtx global rf@latest
```

### [Homebrew](https://brew.sh/)

```sh
brew tap buty4649/tap
brew install buty4649/tap/rf
```

### [GitHub CLI](https://cli.github.com/) and [k1LoW/gh-setup](https://github.com/k1LoW/gh-setup/)

```sh
# if not installed k1LoW/gh-setup
gh extension install k1LoW/gh-setup
gh setup --repo buty4649/rf --bin-dir ~/.local/bin
```

## Options

```sh
Usage: rf [options] 'command' file ...
  -t, --type={text|json|yaml}      set the type of input (default:text)
  -j, --json                       equivalent to -tjson
  -y, --yaml                       equivalent to -tyaml
      --debug                      enable debug mode
  -n, --quiet                      suppress automatic priting
  -h, --help                       show this message
  -v, --version                    show version

text options:
  -F, --filed-separator VAL        set the field separator(regexp)
```

If you don't specify *file*, it will be read from standard input.

## Command

Write Ruby code in *command*.
In rf, this Ruby code is called **command**.
rf uses [mruby](https://github.com/mruby/mruby) as a Ruby processing system.
mruby is a lightweight Ruby processing system designed for embedded systems.
It is compatible with CRuby and can use almost all functions, but there are some function restrictions.
For more information, please refer to [mruby documentation](https://github.com/mruby/mruby/blob/master/doc/limitations.md).

## Filter

In rf, processing is performed in the following way.

1. Read data from *file* or standard input.
2. Convert the read data into a format that is easy to handle with Ruby.
3. Divide the converted data.
4. Execute *command* and evaluate the result.
5. Process the evaluation result and output it.
6. Repeat steps 3 through 5 until there is no more data.

The functions that perform steps 2, 3 and 5 are called **filters** in rf.
If you express this process flow in pseudo-code of Ruby, it will be as follows.

```ruby
Filter.read(input).each do |record|
  puts eval(command)
end
```

### Record

Filters divide input data according to certain rules.
In rf, this divided unit is called **record**.
The rules for dividing vary depending on the filter.

In text filters, they are divided by newline codes (`\n`).
In JSON filters/YAML filters, they are divided by object units. For example, if the input data is an array, it will be divided into each element of the array.
If expressed in Ruby code, it will be processed as follows.

```ruby
# In case of YAML filter it will be YAML.load
[JSON.load(input)].flatten(1).each do |record|
  puts eval(command)
end
```

### Field

In rf, the part that is further divided from the record is called **field**. By using the special variable `_1`, `_2`, `_3`, etc., you can access the first field, second field, third field, etc. The field division is done automatically, but you can access records that are not divided into fields by using the `_` variable.

The field division rule varies depending on the filter. In the case of a text filter, it is separated by whitespace characters. It behaves the same as when String#split is called without arguments. By specifying the `-F` option, you can change the delimiter. It is also possible to use regular expressions as delimiters. JSON filters/YAML filters only divide into fields if the record is an array. If it is another data type, only `_1` will be stored and `_2` and later will be nil.

## Special variables

In rf, you can use [special variables](https://docs.ruby-lang.org/ja/latest/class/Kernel.html) defined in Ruby. However, some variables have been changed to rf's own definitions.

| Variable name | Description |
|-------|------|
| record, \_, $\_, \_0  | The input record |
| fields, $F | It is an array that stores fields(`$F=_.split`) |
| \_1, \_2, \_3, ... | First field, second field, third field... |
| $., @NR | The number of records loaded(1-indexed) |

## Built-in methods

Several methods are built-in for convenience.

| Method name | Description |
|-----------|------|
| gsub | Same as `_.gsub` |
| gsub! | Same as `_.gsub!` |
| match | Same as `_.match` |
| match? | Same as `_.match?` |
| sub | Same as `_.sub` |
| sub! | Same as `_.sub!` |
| tr | Same as `_.tr` |
| tr! | Same as `_.tr!` |

## Extensions

rf extends Ruby's language features.

### Automatic conversion of to_i/to_f

In standard Ruby, String and Integer/Float cannot be calculated directly.
You need to call String#to_i or String#to_f.
rf automatically performs these calls.

```ruby
1 + "1"
#=> 2
```

### Hash key can be specified as a method

You can call a key in a Hash as a method.

```ruby
h = {"a": 1}
h.a
#=> 1
```

If you call an undefined key as a method, it will become undefined method.

```ruby
h.b
#=> Error: undefined method 'b'
```

You cannot call keys that contain whitespace characters, symbols or multibyte characters in this way. Use `Hash#[]`.

## License

See [LICENSE](LICENSE) © [buty4649](https://github.com/buty4649/)
