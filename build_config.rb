require 'shellwords'

def gem_config(conf)
  conf.gembox 'default'
  conf.gem File.expand_path(__dir__)
end

def debug_config(conf)
  conf.enable_bintest
  conf.enable_test
  conf.enable_debug
end

def linux_build_config(conf, target = nil, strip: false)
  commands = %w[zig cc]
  commands << '-s' if strip
  commands += ['-target', target] if target
  commands = commands.shelljoin

  conf.cc.command = commands
  conf.linker.command = commands
  conf.archiver.command = 'zig ar'
  conf.cc.defines += %w[MRB_STR_LENGTH_MAX=0 MRB_UTF8_STRING]
  conf.host_target = target if target
end

MRuby::Build.new do |conf|
  linux_build_config(conf)
  debug_config(conf)
  gem_config(conf)
end

build_targets = ENV['MRUBY_BUILD_TARGETS']&.split(',') || []

{
  'linux-x86_64' => 'x86_64-linux-musl',
  'linux-aarch64' => 'aarch64-linux-musl'
}.each do |(arch, target)|
  next unless build_targets.include?(arch)

  MRuby::CrossBuild.new(arch) do |conf|
    linux_build_config(conf, target, strip: true)
    debug_config(conf)
    gem_config(conf)
  end
end

if build_targets.include?('darwin-x86_64')
  MRuby::CrossBuild.new('darwin-x86_64') do |conf|
    macos_sdk = ENV.fetch('MACOSX_SDK_PATH').shellescape

    command = ['zig', 'cc', '-target', 'x86_64-macos', '-Wno-overriding-t-option', '-mmacosx-version-min=10.14']
    conf.cc.command = (command + ['-isysroot', macos_sdk, '-iwithsysroot',
                                  '/usr/include', '-iframeworkwithsysroot',
                                  '/System/Library/Frameworks']).join(' ')
    conf.linker.command = (command + ['--sysroot', macos_sdk, '-F/System/Library/Frameworks', '-L/usr/lib']).shelljoin
    conf.archiver.command = 'zig ar'
    ENV['RANLIB'] ||= 'zig ranlib'
    conf.host_target = 'x86_64-darwin'

    debug_config(conf)
    gem_config(conf)
  end
end

if build_targets.include?('darwin-aarch64')
  MRuby::CrossBuild.new('darwin-aarch64') do |conf|
    macos_sdk = ENV.fetch('MACOSX_SDK_PATH').shellescape

    command = ['zig', 'cc', '-target', 'aarch64-macos', '-Wno-overriding-t-option', '-mmacosx-version-min=11.1']
    conf.cc.command = (command + ['-isysroot', macos_sdk, '-iwithsysroot',
                                  '/usr/include', '-iframeworkwithsysroot',
                                  '/System/Library/Frameworks']).join(' ')
    conf.linker.command = (command + ['--sysroot', macos_sdk, '-F/System/Library/Frameworks', '-L/usr/lib']).shelljoin
    conf.archiver.command = 'zig ar'
    ENV['RANLIB'] ||= 'zig ranlib'
    conf.host_target = 'x86_64-darwin'

    debug_config(conf)
    gem_config(conf)
  end
end
