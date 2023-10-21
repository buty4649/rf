require 'shellwords'
require_relative 'mrblib/rf/version'

IMAGE_NAME = 'buty4649/mruby-build:master'

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
    windows-amd64
  ]
end

def archive_binary_file(targets, version)
  FileUtils.mkdir_p 'release'
  targets.each do |target|
    ext = '.exe' if target =~ /windows/
    src = File.expand_path("build/#{target}/bin/rf#{ext}")
    dest = File.expand_path("release/rf-#{version}-#{target}")

    if target =~ /linux/
      sh "tar -zcf #{dest}.tar.gz -C #{File.dirname(src)} #{File.basename(src)}"
    else
      sh "zip -j #{dest}.zip #{src}"
    end
  end
  Dir.chdir('release') do
    sh 'sha256sum *.tar.gz *.zip > checksums.txt'
  end
end

task default: :build

desc 'Build the project'
task 'build' do
  docker_run
end

namespace :build do
  desc 'Build the project for all targets'
  task 'all' do
    build_targets.each do |target|
      Rake::Task["build:#{target}"].invoke
    end
  end

  build_targets.each do |target|
    desc "Build the project for #{target}"
    task target do
      env = ["MRUBY_BUILD_TARGETS=#{target}"]
      docker_run(env:)
    end
  end

  desc 'Build assets files for all targets'
  task assets: %w[clean build:all] do
    archive_binary_file(build_targets, "v#{Rf::VERSION}")
  end
end

desc 'Cleanup build cache'
task 'clean' do
  docker_run(cmd: 'clean')
end

desc 'Deep cleanup build cache'
task 'deep_clean' do
  env = ["MRUBY_BUILD_TARGETS=#{build_targets.join(',')}"]
  docker_run(cmd: 'deep_clean', env:)
end

desc 'Bumpup minor version and release'
task 'release' do
  version = Rf::VERSION
  sh "git tag v#{version}"
  sh "git push origin v#{version}"
end

desc 'Run RSpec with parallel_rspec'
task 'spec' do
  sh 'parallel_rspec --first-is-1'
end
