require 'shellwords'

def gem_config(conf)
  conf.gembox 'default'

  conf.gem mgem: 'mruby-env'
  conf.gem github: 'mrbgems/mruby-tempfile'

  conf.gem github: 'buty4649/magni', branch: 'main' do |g|
    g.bins = %w[rf]
  end
  conf.gem github: 'buty4649/mruby-commit-id', branch: 'main'
  conf.gem github: 'buty4649/mruby-yyjson', branch: 'main'
  conf.gem github: 'buty4649/mruby-rapidyaml', branch: 'main'
  conf.gem github: 'buty4649/mruby-onig-regexp'
end

def debug_config(conf)
  # conf.enable_bintest
  # conf.enable_test
  conf.enable_debug
end

def build_config(conf, target = nil, strip: false)
  flags = build_flags(target, strip)

  conf.enable_cxx_exception

  conf.cc.command = 'zig cc'
  conf.cc.flags += flags

  conf.cxx.command = 'zig c++'
  conf.cxx.flags += flags

  conf.linker.command = 'zig c++'
  conf.linker.flags += flags

  build_cc_defines(conf)

  conf.archiver.command = 'zig ar'
  conf.host_target = target if target
end

def build_flags(target, strip)
  flags = %w[-O3]
  flags += ['-target', target] if target
  flags += %w[-mtune=native -march=native] if target == 'x86_64-linux-musl'
  flags << '-s' if strip
  flags
end

def build_cc_defines(conf)
  [conf.cc, conf.cxx].each do |cc|
    cc.defines += %w[MRB_STR_LENGTH_MAX=0 MRB_UTF8_STRING MRUBY_YAML_NO_CANONICAL_NULL MRB_IREP_LVAR_MERGE_LIMIT=240
                     MRB_ARY_LENGTH_MAX=0]
  end
end

MRuby::Build.new do |conf|
  build_config(conf)
  debug_config(conf)
  gem_config(conf)
end

build_targets = ENV['MRUBY_BUILD_TARGETS']&.split(',') || []

{
  'linux-amd64' => 'x86_64-linux-gnu',
  'linux-arm64' => 'aarch64-linux-gnu'
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
    cc_flags = ['-Wno-overriding-option', '-mmacosx-version-min=11.1',
                '-isysroot', macos_sdk, '-iwithsysroot', '/usr/include',
                '-iframeworkwithsysroot', '/System/Library/Frameworks']
    conf.cc.flags += cc_flags
    conf.cxx.flags += cc_flags

    conf.linker.flags += ['-Wno-overriding-option', '-mmacosx-version-min=11.1',
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
    conf.build_target     = 'x86_64-pc-linux-gnu'
    conf.host_target      = 'x86_64-w64-mingw32'

    conf.enable_cxx_exception
    conf.cc.command = "#{conf.host_target}-gcc"

    conf.cxx.command = "#{conf.host_target}-g++"
    conf.cxx.defines += %w[_WIN32]

    build_cc_defines(conf)

    conf.linker.command = "#{conf.host_target}-g++"
    conf.linker.flags += %w[-static -O3 -s]
    conf.linker.libraries += %w[pthread]

    conf.archiver.command = "#{conf.host_target}-ar"

    conf.exts do |exts|
      exts.object = '.obj'
      exts.executable = '.exe'
      exts.library = '.lib'
    end

    debug_config(conf)
    gem_config(conf)
  end
end
