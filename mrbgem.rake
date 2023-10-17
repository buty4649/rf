require_relative 'mrblib/rf/version'

MRuby::Gem::Specification.new('rf') do |spec|
  spec.bins = %w[rf]
  spec.license = 'MIT'
  spec.author = 'buty4649'
  spec.summary = 'rf is Ruby powered text/json/yaml filter'
  spec.version = Rf::VERSION

  spec.add_dependency 'mruby-binding', core: 'mruby-binding'

  %w[
    mruby-json
    mruby-optparse
  ].each do |mgem|
    spec.add_dependency mgem, mgem:
  end
  spec.add_dependency 'mruby-yaml',        github: 'buty4649/mruby-yaml'
  spec.add_dependency 'mruby-onig-regexp', github: 'buty4649/mruby-onig-regexp'
end
