MRuby::Gem::Specification.new('rf') do |spec|
  spec.bins = %w[rf]
  spec.license = 'MIT'
  spec.author = 'buty4649'
  spec.summary = 'rf is Ruby powered text/json/yaml filter'
  spec.version = '0.1.0'

  %w[
    mruby-json
    mruby-onig-regexp
    mruby-optparse
    mruby-yaml
  ].each do |mgem|
    spec.add_dependency mgem, mgem:
  end
end
