require_relative 'mrblib/rf/version'

MRuby::Gem::Specification.new('rf') do |spec|
  spec.bins = %w[rf]
  spec.license = 'MIT'
  spec.author = 'buty4649'
  spec.summary = 'rf is Ruby powered text/json/yaml filter'
  spec.version = Rf::VERSION

  spec.add_dependency 'mruby-binding', core: 'mruby-binding'

  spec.add_dependency 'mruby-optparse', mgem: 'mruby-optparse'

  spec.add_dependency 'mruby-tempfile', github: 'mrbgems/mruby-tempfile'
  spec.add_dependency 'mruby-commit-id', github: 'buty4649/mruby-commit-id', branch: 'main'
  spec.add_dependency 'mruby-yyjson', github: 'buty4649/mruby-yyjson', branch: 'main'
  spec.add_dependency 'mruby-rapidyaml', github: 'buty4649/mruby-rapidyaml', branch: 'main'
  spec.add_dependency 'mruby-onig-regexp', github: 'buty4649/mruby-onig-regexp'
end
