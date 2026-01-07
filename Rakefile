require 'shellwords'
require_relative 'mrblib/rf/version'

def build_targets
  %w[
    linux-amd64 linux-arm64
    darwin-arm64
    windows-amd64
  ]
end

def invoke_mruby_task(name)
  rakefile = File.join(__dir__, 'mruby', 'Rakefile')
  verbose = Rake.application.options.silent ? '' : '-v'
  sh "rake -f #{rakefile} -mj1 #{verbose} #{name}"
end

def archive_binary_file(targets, version)
  FileUtils.mkdir_p 'release'
  targets.each do |target|
    ext = '.exe' if target.include?('windows')
    src = File.expand_path("build/#{target}/bin/rf#{ext}")
    dest = File.expand_path("release/rf-#{version}-#{target}")

    if target.include?('linux')
      sh "tar -zcf #{dest}.tar.gz -C #{File.dirname(src)} #{File.basename(src)}"
    else
      sh "zip -j #{dest}.zip #{src}"
    end
  end
  Dir.chdir('release') do
    sh 'sha256sum *.tar.gz *.zip > checksums.txt'
  end
end

task default: ['build:host', 'spec']

desc 'Build binary (host)'
task 'build' do
  Rake::Task['build:host'].invoke
end

namespace 'build' do
  (%w[host all] + build_targets).each do |target|
    desc "Build binary (#{target})"
    task target do
      if target == 'all'
        ENV['MRUBY_BUILD_TARGETS'] = build_targets.join(',')
      elsif target != 'host'
        ENV['MRUBY_BUILD_TARGETS'] = target
      end
      ENV['MRUBY_BUILD_DIR'] = ENV['MRUBY_BUILD_DIR'] || File.join(__dir__, 'build')

      invoke_mruby_task('all')
    end
  end
end

desc 'Cleanup build directory'
task 'clean' do
  invoke_mruby_task('clean')
end

desc 'Run RSpec with parallel_rspec'
task 'spec' do
  sh 'parallel_rspec --first-is-1'
end
