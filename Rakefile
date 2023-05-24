require 'shellwords'
require_relative 'mrblib/rf/version'

IMAGE_NAME = 'buty4649/mruby-build:3.2.0'

def docker_run(cmd: nil, env: nil)
  env_opts = env&.map { |e| ['-e', e] }
  cmds = [
    'docker', 'run', '--rm', '-v', "#{Dir.getwd}:/src".shellescape,
    env_opts, IMAGE_NAME, cmd&.shellescape
  ]
  sh cmds.flatten.compact.join(' ')
end

def build_targets
  %w[
    linux-amd64 linux-arm64
    darwin-amd64 darwin-arm64
  ]
end

task default: :build

desc 'Build the project'
task 'build' do
  docker_run
end

namespace :build do
  desc 'Build the project for all targets'
  task 'all' do
    env = ["MRUBY_BUILD_TARGETS=#{build_targets.join(',')}"]
    docker_run(env:)
  end
end

desc 'Cleanup build cache'
task 'clean' do
  docker_run(cmd: 'clean')
end

desc 'Deep cleanup build cache'
task 'deep_clean' do
  docker_run(cmd: 'deep_clean')
end

desc 'Release the project'
task release: %w[clean build:all] do
  FileUtils.mkdir_p 'release'
  build_targets.each do |target|
    src = File.expand_path("build/#{target}/bin/rf")
    dest = File.expand_path("release/rf-v#{Rf::VERSION}-#{target}")

    if target =~ /linux/
      sh "fakeroot -- tar -cf #{dest}.tar.gz -C #{File.dirname(src)} #{File.basename(src)}"
    else
      sh "fakeroot -- zip -j #{dest}.zip #{src}"
    end
  end
end

desc 'Run RSpec with parallel_rspec'
task 'spec' do
  sh 'parallel_rspec --first-is-1'
end
