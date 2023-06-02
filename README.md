# rf

**rf** is a CLI tool written in Ruby that allows you to filter text/JSON/YAML files using code. While tools like **awk**, **jq**, and **yq** can be used to process these files, they require learning their respective usage and syntax. **rf** allows you to accomplish similar tasks using Ruby code, making it a familiar tool for Rubyists.

**rf** is built using [mruby](https://github.com/mruby/mruby) and consists of a standalone binary file. There is no need to install Ruby separately to use **rf**. You can start using it immediately by downloading the binary file, making it a convenient feature.

## Quick Start Guide

Replace a part of the text:

```sh
rf 'gsub(/hello/, "world")' example.txt
```

Read from standard input:

```sh
rf 'gsub(/hello/, "world")' < example.txt
```

Display only the lines that contain a specific pattern:

```sh
rf '/hello/' example.txt
```

You can use UTF-8 patterns:

```sh
rf '/🍣/' example.txt
```

Add the second column of a comma-separated file:

```sh
rf -F, 's||=0;s+=_2; at_exit{putts s}' example.csv
```

Output a specific key from a JSON file:

```sh
rf -j '.a.b' example.json
```

Output a specific key from a YAML file:

```sh
rf -y '.a.b' example.json
```

## Installation

You can download **rf** from the [Release page](https://github.com/buty4649/rf/releases). Binary files are provided for various platforms and architectures. Please refer to the following table for compatibility:

|     | amd64 | arm64 |
|-----|-------|-------|
|Linux|✅    |✅     |
|MacOS|✅    |✅     |
|Windows|✅  |-      |

Alternatively, you can install it using various package managers.

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
  -n, --quiet                      suppress automatic printing
  -h, --help                       show this message


 -v, --version                    show version

text options:
  -F, --filed-separator VAL        set the field separator (regexp)
```

If no *file* is specified, it will read from standard input.

## Command

The *command* in rf is where you write Ruby code. In rf, this Ruby code is referred to as the **command**. rf uses [mruby](https://github.com/mruby/mruby) as the Ruby interpreter. mruby is a lightweight Ruby implementation designed for embedded systems. It is mostly compatible with CRuby and supports most of its features, with some limitations. For more details, please refer to the [mruby documentation](https://github.com/mruby/mruby/blob/master/doc/limitations.md).

## Filters

In rf, the processing is done following these steps:

1. Read data from *file* or standard input.
2. Convert the read data into a format that is easy to handle in Ruby.
3. Split the converted data into chunks.
4. Execute the *command* and evaluate the result.
5. Process and output the evaluation result.
6. Repeat steps 3 to 5 until there is no more data.

The functionalities responsible for steps 2, 3, and 5 are referred to as **filters** in rf. This processing flow can be represented in pseudo Ruby code as follows:

```ruby
Filter.read(input).each do |chunk|
  puts eval(command)
end
```

### Chunks

Filters split the input data according to certain rules. These divided units are called **chunks** in rf. The splitting rules vary depending on the filter.

In the text filter, the chunks are split by the newline character (`\n`). For JSON and YAML filters, the chunks are split on an object level. For example, if the input data is an array, it will be split into chunks based on the elements of the array. In Ruby code, it can be represented as follows:

```ruby
# For the YAML filter, it would be YAML.load
[JSON.load(input)].flatten(1).each do |chunk|
  puts eval(command)
end
```

### Fields

Fields are further subdivisions of chunks in rf. Using special variables like `_1`, `_2`, `_3`, and so on, you can access the first field, second field, third field, and so on. Field splitting is done automatically, but you can access the chunk that has not been split into fields using the `_` variable.

The rules for field splitting vary depending on the filter. In the text filter, fields are separated by whitespace characters. It behaves the same as calling `String#split` without any arguments. You can change the field separator by using the `-F` option, and it is also possible to use a regular expression as the separator. For JSON and YAML filters, fields are only split if the chunk is an array. If the chunk is of any other data type, only `_1` will be populated, and `_2` onwards will be `nil`.

## Special Variables

In rf, you can use the [special variables](https://docs.ruby-lang.org/en/latest/class/Kernel.html) defined in Ruby. However, some variables have been redefined in rf for its own purposes.

| Variable | Description |
|----------|-------------|
| \_       | The input chunk |
| $\_      | Alias for \_ |
| $F       | Alias for \_ |
| \_1, \_2, \_3, ... | The first, second, third field, and so on |

## Built-in Methods

For convenience, rf provides several methods as built-in methods.

| Method | Description |
|--------|-------------|
| gsub   | Equivalent to `_.gsub` |
| gsub!  | Equivalent to `_.gsub

!` |
| match  | Equivalent to `_.match` |
| match? | Equivalent to `_.match?` |
| sub    | Equivalent to `_.sub` |
| sub!   | Equivalent to `_.sub!` |
| tr     | Equivalent to `_.tr` |
| tr!    | Equivalent to `_.tr!` |

## Extensions

rf extends the Ruby language with its own additional features.

### Automatic conversion of to_i/to_f

In standard Ruby, you cannot directly perform calculations between a String and an Integer/Float. You need to call String#to_i or String#to_f. However, rf automatically performs these conversions for you.

```ruby
1 + "1"
#=> 2
```

### Accessing Hash keys as methods

In rf, you can call Hash keys as methods.

```ruby
h = {"a": 1}
h.a
#=> 1
```

If you call a method that doesn't exist as a key, it will result in an undefined method error.

```ruby
h.b
#=> Error: undefined method 'b'
```

You cannot use this method to call keys that contain whitespace, symbols, or multibyte characters. In those cases, use `Hash#[]`.

## License

See [LICENSE](LICENSE) © [buty4649](https://github.com/buty4649/)
