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

def ccache
  'ccache ' if ENV['USE_CCACHE']
end

def build_config(conf, target = nil, strip: false)
  [conf.cc, conf.linker].each do |cc|
    cc.command = "#{ccache}zig cc"
    cc.flags += ['-target', target] if target
    cc.flags << '-s' if strip
  end

  conf.archiver.command = 'zig ar'
  conf.cc.defines += %w[MRB_STR_LENGTH_MAX=0 MRB_UTF8_STRING MRUBY_YAML_NO_CANONICAL_NULL]
  conf.host_target = target if target
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

if build_targets.include?('darwin-amd64')
  MRuby::CrossBuild.new('darwin-amd64') do |conf|
    macos_sdk = ENV.fetch('MACOSX_SDK_PATH').shellescape

    build_config(conf, 'x86_64-macos', strip: true)
    conf.cc.flags += ['-Wno-overriding-t-option', '-mmacosx-version-min=10.14',
                      '-isysroot', macos_sdk, '-iwithsysroot', '/usr/include',
                      '-iframeworkwithsysroot', '/System/Library/Frameworks']
    conf.linker.flags += ['-Wno-overriding-t-option', '-mmacosx-version-min=10.14',
                          '--sysroot', macos_sdk, '-F/System/Library/Frameworks', '-L/usr/lib']
    conf.archiver.command = 'zig ar'
    ENV['RANLIB'] ||= 'zig ranlib'
    conf.host_target = 'x86_64-darwin'

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
    build_config(conf, 'x86_64-windows', strip: true)
    conf.cc.flags << '-lws2_32'
    conf.linker.flags << '-lws2_32'

    conf.exts do |exts|
      exts.object = '.obj'
      exts.executable = '.exe'
      exts.library = '.lib'
    end

    crossbuild_root = File.join(build_dir, 'crossbuild')
    FileUtils.mkdir_p(crossbuild_root)
    crossbuild_lib_path = File.join(crossbuild_root, 'gai_strerror.o')
    crossbuild_src_path = File.join(__dir__, 'crossbuild', 'gai_strerror.c')
    `#{conf.cc.command} #{conf.cc.flags.join(' ')} -o #{crossbuild_lib_path} -c #{crossbuild_src_path}`
    conf.linker.flags << crossbuild_lib_path

    debug_config(conf)
    gem_config(conf)
  end
end
