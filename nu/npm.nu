#!/usr/bin/env nu
# Author: hustcer
# Created: 2023/04/20 20:06:56
# Usage:
#   Publish nushell binaries to npmjs.com
# Unpublish:
#   ['linux-x64' 'linux-riscv64' 'linux-arm' 'linux-arm64' 'darwin-x64' 'darwin-arm64' 'windows-x64'] | each {|it| npm unpublish -f --registry https://registry.npmjs.com/ $'@nushell/($it)' }
#   npm unpublish -f --registry https://registry.npmjs.com/ nushell
# Notes:
#   The difference between the Rust build targets "*-linux-musl" and "*-linux-gnu" is that they use different C libraries.
#   "musl" is a lightweight, statically linked library, whereas "gnu" is a standard, dynamically linked library.
#   Musl has a smaller footprint compared to GNU and is designed to be compatible with as many Linux distributions as possible.
#   This makes it a good choice for building small and statically-linked executables for use in containerized environments or
#   systems with limited resources.
#   On the other hand, the GNU C library is commonly used and has a larger feature set. It is typically used for building larger
#   and dynamically-linked executables which are more flexible but have dependencies on the libraries installed on the system.

# TODO:
#  - [√] Add a Just task to bump version
#  - [√] Add a readme file to the git repo
#  - [√] Use rome to handle code formatting
#  - [√] Rename binary to 'nu' instead of 'nushell'
#  - [√] Add a workflow to test the published package
#  - [√] Unify nu version and npm version
#  - [√] Publish to npm beta tag support
#  - [√] Make the script re-runable: check if the package exists before publish
#  - [√] Refactor: Publish all packages with this script: nushell, @nushell/linux-x64, @nushell/linux-riscv64, etc.
#  - [√] Missing @nushell/windows-arm64

use common.nu [hr-line, is-installed]

let pkgs = [
  'aarch64-apple-darwin'
  'aarch64-unknown-linux-gnu'
  'armv7-unknown-linux-gnueabihf'
  'riscv64gc-unknown-linux-gnu'
  'x86_64-apple-darwin'
  'x86_64-pc-windows-msvc'
  'aarch64-pc-windows-msvc'
  # 'x86_64-unknown-linux-gnu'
  'x86_64-unknown-linux-musl'     # Using musl instead of linux-gnu to make it run more widely.
]

# REF: https://nodejs.org/dist/latest-v18.x/docs/api/process.html#processplatform
# Available values: 'aix', 'darwin', 'freebsd', 'linux', 'openbsd', 'sunos', 'win32'
let os_map = {
  aarch64-apple-darwin: 'darwin',
  aarch64-unknown-linux-gnu: 'linux',
  armv7-unknown-linux-gnueabihf: 'linux',
  riscv64gc-unknown-linux-gnu: 'linux',
  x86_64-apple-darwin: 'darwin',
  x86_64-pc-windows-msvc: 'win32',
  aarch64-pc-windows-msvc: 'win32',
  x86_64-unknown-linux-gnu: 'linux',
  x86_64-unknown-linux-musl: 'linux',
}

# REF: https://nodejs.org/dist/latest-v18.x/docs/api/process.html#processarch
# REF: https://github.com/nodejs/node/issues/41900
# Possible values are: 'arm', 'arm64', 'ia32', 'mips', 'mipsel', 'ppc', 'ppc64', 's390', 's390x', 'x32', 'x64'
let arch_map = {
  aarch64-apple-darwin: 'arm64',
  aarch64-unknown-linux-gnu: 'arm64',
  armv7-unknown-linux-gnueabihf: 'arm',
  riscv64gc-unknown-linux-gnu: 'riscv64',
  x86_64-apple-darwin: 'x64',
  x86_64-pc-windows-msvc: 'x64',
  aarch64-pc-windows-msvc: 'arm64',
  x86_64-unknown-linux-gnu: 'x64',
  x86_64-unknown-linux-musl: 'x64',
}

let __dir = ($env.PWD)
let npm_dir = $'($__dir)/npm'
let pkg_dir = $'($__dir)/pkgs'

# Published npm version for nu binary, just the same as tag version and it could be different from nu version
let NPM_VERSION = $env.RELEASE_VERSION
# The nu version to release, you can fix it to a specific nu version and publish it to different npm version
# eg: npm version: 0.78.0, 0.78.1, 0.78.2, etc. all point to the same nu version: 0.78.0, just set NU_VERSION to 0.78.0
# They are equal to each other by default
# let NU_VERSION = '0.79.0'
let NU_VERSION = ($'($npm_dir)/app/package.json' | open | get nuVer)

# Publish Nu binaries to npmjs.com
def main [
  type: string = 'base',  # Npm publish type: 'base' or 'each'
  --sync,                 # Sync packages to npmmirror.com after publishing
] {
  match $type {
    'base' => { publish-base-pkg --sync=$sync }
    'each' => { publish-each-pkg --sync=$sync }
    _ => { print $'Invalid publish type: ($type)' }
  }
}

def 'publish-each-pkg' [
  --sync,                 # Sync packages to npmmirror.com after publishing
] {
  print $'Current working directory: ($__dir)'
  # print 'Current env:'; print $env
  mkdir pkgs; cd pkgs

  for pkg in $pkgs {
    let is_windows = ($pkg =~ 'windows')
    let bin = if $is_windows { 'nu.exe' } else { 'nu' }
    let p = if $is_windows { $pkg + '.zip' } else { $pkg + '.tar.gz' }
    let nu_pkg = $'nu-($NU_VERSION)-($p)'
    # Unzipped directory contains all binary files
    let bin_dir = if $is_windows { ($nu_pkg | str replace '.zip' '') } else { $nu_pkg | str replace '.tar.gz' '' }
    $env.node_os = ($os_map | get $pkg)
    $env.node_arch = ($arch_map | get $pkg)
    $env.node_version = $NPM_VERSION
    let rls_dir = $'($npm_dir)/($env.node_os)-($env.node_arch)'
    # note: use 'windows' as OS name instead of 'win32'
    $env.node_pkg = if $is_windows { $'@nushell/windows-($env.node_arch)' } else { $'@nushell/($env.node_os)-($env.node_arch)' }

    # Check if the package exists before publish
    let check = (do -i { npm info $'($env.node_pkg)@($NPM_VERSION)' --registry=https://registry.npmjs.com/ | complete })
    if $check.exit_code == 0 {
      print $'Package ($env.node_pkg)@($NPM_VERSION) already exists, skip publishing'
      continue
    }

    # Download the package and prepare for publishing
    print $'Downloading ($nu_pkg)...'
    let download = (aria2c $'https://github.com/nushell/nushell/releases/download/($NU_VERSION)/($nu_pkg)' | complete)
    if ($download.exit_code != 0) {
      print $'Download ($nu_pkg) failed, skip publishing'
      continue
    }
    if $is_windows { unzip $nu_pkg -d $bin_dir } else { tar xvf $nu_pkg }

    cd $npm_dir
    # create the package directory
    mkdir $'($rls_dir)/bin'
    # generate package.json from the template
    open package.json.tmpl
        | str replace '${node_os}' $env.node_os
        | str replace '${node_pkg}' $env.node_pkg
        | str replace '${node_arch}' $env.node_arch
        | str replace '${node_version}' $NPM_VERSION
        | save -f $'($rls_dir)/package.json'
    # copy the binary into the package
    # note: windows binaries has '.exe' extension
    hr-line
    print $'Going to cp: ($pkg_dir)/($bin_dir)/($bin) to release directory...'
    cp ($'($__dir)/README.*' | into glob) $rls_dir
    cp $'($pkg_dir)/($bin_dir)/LICENSE' $rls_dir
    cp $'($pkg_dir)/($bin_dir)/($bin)' $'($rls_dir)/bin'
    # publish the package
    cd $rls_dir
    let dist_tag = ($'($npm_dir)/app/package.json' | open | get distTag)
    print $'Publishing package: ($env.node_pkg) to ($dist_tag) tag...'; hr-line
    npm publish --access public --tag $dist_tag --registry https://registry.npmjs.com/
    cd $pkg_dir
  }
  print (char nl)
  print 'Npm directory tree:'; hr-line
  tree $npm_dir
  print 'Pkg directory tree:'; hr-line
  tree $pkg_dir
  if not $sync { return }

  print 'Start to sync packages to npmmirror.com ...'; hr-line
  if not (is-installed cnpm) {
    npm i --location=global cnpm --registry=https://registry.npmmirror.com
  }
  open $'($npm_dir)/app/package.json'
      | get optionalDependencies
      | columns
      | each {|it| cnpm sync $it; hr-line -a }

  print 'All packages have been published successfully:'
}

def 'publish-base-pkg' [
  --sync,                 # Sync packages to npmmirror.com after publishing
] {
  print $'Current working directory: ($__dir)'
  # print 'Current env:'; print $env
  let version = ('npm/app/package.json' | open | get version)
  # Check if the package exists before publish
  let check = (do -i { npm info $'nushell@($version)' --registry=https://registry.npmjs.com/ | complete })
  if $check.exit_code == 0 {
    print $'Package nushell@($version) already exists, skip publishing'
    exit 0
  }

  if not (is-installed cnpm) {
    npm i --location=global cnpm pnpm --registry=https://registry.npmmirror.com
  }
  # Download the package and publish it
  cp README.* npm/app/; cd npm/app
  aria2c https://raw.githubusercontent.com/nushell/nushell/main/LICENSE
  # requires optional dependencies to be present in the registry
  # Cannot install with "frozen-lockfile" because pnpm-lock.yaml is not up to date with package.json
  pnpm install --no-frozen-lockfile; pnpm build
  let tag = ('package.json' | open | get distTag)
  print $'Publishing nushell package to npm ($tag) tag...'
  npm publish --access public --tag $tag --registry https://registry.npmjs.com/
  print $'(char nl)Start to sync packages to npmmirror.com ...'
  if $sync { cnpm sync nushell }
}
