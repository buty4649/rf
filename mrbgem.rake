MRuby::Gem::Specification.new('rf') do |spec|
  spec.bins = %w[rf]
  spec.license = 'MIT'
  spec.author = 'buty4649'
  spec.summary = 'rf is Ruby powered text/json/yaml filter'
  spec.version = '0.1.0'

  %w[
    mruby-array-ext
    mruby-binding
    mruby-dir
    mruby-enum-ext
    mruby-enumerator
    mruby-eval
    mruby-exit
    mruby-hash-ext
    mruby-io
    mruby-math
    mruby-metaprog
    mruby-numeric-ext
    mruby-print
    mruby-random
    mruby-sprintf
    mruby-string-ext
    mruby-time
  ].each do |core|
    spec.add_dependency core, core:
  end

  %w[
    mruby-onig-regexp
    mruby-optparse
    mruby-yaml
  ].each do |mgem|
    spec.add_dependency mgem, mgem:
  end

  {
    'mruby-json' => 'mattn/mruby-json'
  }.each do |(mgem, repo)|
    spec.add_dependency mgem, github: repo
  end
end
