#!/usr/bin/env nu
# Author: hustcer
# Created: 2023/04/20 20:06:56
# Usage:
#   Publish nushell binaries to npmjs.com
# Unpublish:
#   ['linux-x64' 'linux-riscv64' 'linux-arm' 'linux-arm64' 'darwin-x64' 'darwin-arm64' 'windows-x64'] | each {|it| npm unpublish -f --registry https://registry.npmjs.com/ $'@nushell/($it)' }
#   npm unpublish -f --registry https://registry.npmjs.com/ nushell

# TODO:
#  - [√] Add a Just task to bump version
#  - [√] Add a readme file to the git repo
#  - [√] Use rome to handle code formatting
#  - [√] Rename binary to 'nu' instead of 'nushell'
#  - [ ] Add a workflow to test the published package
#  - [ ] Unify nu version and npm version
#  - [ ] Missing @nushell/windows-arm64

let version = '0.78.0'      # nu version
let pkgs = [
    'aarch64-apple-darwin'
    'aarch64-unknown-linux-gnu'
    'armv7-unknown-linux-gnueabihf'
    'riscv64gc-unknown-linux-gnu'
    'x86_64-apple-darwin'
    'x86_64-pc-windows-msvc'
    'x86_64-unknown-linux-gnu'
    # 'x86_64-unknown-linux-musl'
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
    x86_64-unknown-linux-gnu: 'x64',
    x86_64-unknown-linux-musl: 'x64',
}

let __dir = ($env.PWD)
print $'Current working directory: ($__dir)'
print 'Current env:'; print $env
mkdir pkgs; cd pkgs
let npm_dir = $'($__dir)/npm'
let pkg_dir = $'($__dir)/pkgs'
for pkg in $pkgs {
    let is_windows = ($pkg =~ 'windows')
    let bin = if $is_windows { 'nu.exe' } else { 'nu' }
    let p = if $is_windows { $pkg + '.zip' } else { $pkg + '.tar.gz' }
    let nu_pkg = $'nu-($version)-($p)'
    # Unzipped directory contains all binary files
    let bin_dir = if $is_windows { ($nu_pkg | str replace '.zip' '') } else { $nu_pkg | str replace '.tar.gz' '' }
    print $'Downloading ($nu_pkg)...'
    aria2c $'https://github.com/nushell/nushell/releases/download/($version)/($nu_pkg)'
    if $is_windows { unzip $nu_pkg -d $bin_dir } else { tar xvf $nu_pkg }

    let-env node_os = ($os_map | get $pkg)
    let-env node_arch = ($arch_map | get $pkg)
    let-env node_version = $env.RELEASE_VERSION
    let rls_dir = $'($npm_dir)/($env.node_os)-($env.node_arch)'
    # note: use 'windows' as OS name instead of 'win32'
    let-env node_pkg = if $is_windows { $'@nushell/windows-($env.node_arch)' } else { $'@nushell/($env.node_os)-($env.node_arch)' }
    cd $npm_dir
    # create the package directory
    mkdir $'($rls_dir)/bin'
    # generate package.json from the template
    open package.json.tmpl
        | str replace -s '${node_os}' $env.node_os
        | str replace -s '${node_pkg}' $env.node_pkg
        | str replace -s '${node_arch}' $env.node_arch
        | str replace -s '${node_version}' $env.node_version
        | save $'($rls_dir)/package.json'
    # copy the binary into the package
    # note: windows binaries has '.exe' extension
    hr-line
    print $'Going to cp: ($pkg_dir)/($bin_dir)/($bin) to release directory...'
    cp $'($__dir)/README.*' $rls_dir
    cp $'($pkg_dir)/($bin_dir)/LICENSE' $rls_dir
    cp $'($pkg_dir)/($bin_dir)/($bin)' $'($rls_dir)/bin'
    # publish the package
    cd $rls_dir
    print $'Publishing package: ($env.node_pkg)...'; hr-line
    npm publish --access public --tag latest
    cd $pkg_dir
}

print 'Start to sync packages to npmmirror.com ...'; hr-line
npm i --location=global cnpm --registry=https://registry.npmmirror.com
cnpm sync nushell
open $'($npm_dir)/app/package.json' | get optionalDependencies | columns | each {|it| cnpm sync $it; hr-line }

print 'All packages downloaded and published successfully:'
print 'Npm directory tree:'; hr-line
tree $npm_dir
print 'Pkg directory tree:'; hr-line
tree $pkg_dir

# Print a horizontal line marker
def 'hr-line' [
    --blank-line(-b): bool
] {
    print $'(ansi g)---------------------------------------------------------------------------->(ansi reset)'
    if $blank_line { char nl }
}
