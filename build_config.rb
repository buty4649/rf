require 'shellwords'

def gem_config(conf)
  conf.gembox 'default'
  conf.gem File.expand_path(__dir__)
end

def debug_config(conf)
  # conf.enable_bintest
  # conf.enable_test
  conf.enable_debug
end

def build_config(conf, target = nil, strip: false)
  flags = %w[-O3]
  flags += ['-target', target] if target
  flags += %w[-mtune=native -march=native] if target == 'x86_64-linux-musl'
  flags << '-s' if strip

  [conf.cc, conf.linker].each do |cc|
    cc.command = 'zig cc'
    cc.flags += flags
  end
  build_cc_defines(conf)

  conf.archiver.command = 'zig ar'
  conf.host_target = target if target
end

def build_cc_defines(conf)
  conf.cc.defines += %w[MRB_STR_LENGTH_MAX=0 MRB_UTF8_STRING MRUBY_YAML_NO_CANONICAL_NULL MRB_IREP_LVAR_MERGE_LIMIT=240
                        MRB_ARY_LENGTH_MAX=0]
end

MRuby::Build.new do |conf|
  build_config(conf)
  debug_config(conf)
  gem_config(conf)
end

build_targets = ENV['MRUBY_BUILD_TARGETS']&.split(',') || []

{
  'linux-amd64' => 'x86_64-linux-musl',
  'linux-arm64' => 'aarch64-linux-musl'
}.each do |(arch, target)|
  next unless build_targets.include?(arch)

  MRuby::CrossBuild.new(arch) do |conf|
    build_config(conf, target, strip: true)
    debug_config(conf)
    gem_config(conf)
  end
end

if build_targets.include?('darwin-arm64')
  MRuby::CrossBuild.new('darwin-arm64') do |conf|
    macos_sdk = ENV.fetch('MACOSX_SDK_PATH').shellescape

    build_config(conf, 'aarch64-macos', strip: true)
    conf.cc.flags += ['-Wno-overriding-t-option', '-mmacosx-version-min=11.1',
                      '-isysroot', macos_sdk, '-iwithsysroot', '/usr/include',
                      '-iframeworkwithsysroot', '/System/Library/Frameworks']
    conf.linker.flags += ['-Wno-overriding-t-option', '-mmacosx-version-min=11.1',
                          '--sysroot', macos_sdk, '-F/System/Library/Frameworks', '-L/usr/lib']

    conf.archiver.command = 'zig ar'
    ENV['RANLIB'] ||= 'zig ranlib'
    conf.host_target = 'aarch64-darwin'

    debug_config(conf)
    gem_config(conf)
  end
end

if build_targets.include?('windows-amd64')
  MRuby::CrossBuild.new('windows-amd64') do |conf|
    toolchain :gcc

    conf.build_target     = 'x86_64-pc-linux-gnu'
    conf.host_target      = 'x86_64-w64-mingw32'

    [conf.cc, conf.linker].each do |cc|
      cc.command = "#{conf.host_target}-gcc-posix"
      cc.flags += %w[-static -O3 -s]
    end
    build_cc_defines(conf)
    conf.cxx.command      = "#{conf.host_target}-g++"
    conf.archiver.command = "#{conf.host_target}-gcc-ar"

    conf.exts do |exts|
      exts.object = '.obj'
      exts.executable = '.exe'
      exts.library = '.lib'
    end

    debug_config(conf)
    gem_config(conf)
  end
end
