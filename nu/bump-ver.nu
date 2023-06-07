#!/usr/bin/env nu

# TODO:
#   - [√] Check if the tag of the specified version already exists in local git repository

use common.nu [has-ref]

def main [
  version: string,
  --nu-ver: string,
  --dist-tag: string = 'latest',
] {

  let PKG_MAP = {
    '@nushell/darwin-arm64': 'aarch64-apple-darwin',
    '@nushell/darwin-x64': 'x86_64-apple-darwin',
    '@nushell/linux-arm': 'armv7-unknown-linux-gnueabihf',
    '@nushell/linux-arm64': 'aarch64-unknown-linux-gnu',
    '@nushell/linux-riscv64': 'riscv64gc-unknown-linux-gnu',
    '@nushell/linux-x64': 'x86_64-unknown-linux-musl',
    '@nushell/windows-arm64': 'aarch64-pc-windows-msvc',
    '@nushell/windows-x64': 'x86_64-pc-windows-msvc',
  }

  if not ($version | str replace '^(\d+\.)?(\d+\.)?(\*|\d+)$' '' -a | is-empty) {
    print $'(ansi r)Invalid version number: ($version)(ansi reset)'
    exit 7
  }

  if (has-ref $'v($version)') {
    print $'(ansi r)The tag of the specified version already exists: ($version)(ansi reset)'
    exit 5
  }

  let nuVer = if ($nu_ver | is-empty) { $version } else { $nu_ver }

  # Query latest: https://api.github.com/repos/nushell/nushell/releases/latest
  let queryRls = (http get -e $'https://api.github.com/repos/nushell/nushell/releases/tags/($nuVer)')
  if ($queryRls | get -i message | default '' | str contains -i 'Not Found') {
    print $'The specified release (ansi r)($version) does not exist(ansi reset), please check the version number again.'
    exit 3
  }

  let binaries = ($queryRls | get assets | select name)

  let file = 'npm/app/package.json'
  # Filter out the binaries that are not released
  let released = {|x| ($binaries | find ($PKG_MAP | get $x.pkg) | length) > 0 }
  $file
    | open
    | update nuVer $nuVer       # Nushell version to download and release to npm
    | update version $version   # Nushell will be released under this npm version
    | update distTag $dist_tag  # Nushell will be released to this npm dist-tag
    | update optionalDependencies {|it| ($PKG_MAP | transpose k v | update v $version | transpose -r | into record) }
    | update optionalDependencies {|it| ($it.optionalDependencies | rotate --ccw pkg ver | filter $released | transpose -r | into record) }
    | save -f $file

  rome format --write npm/app
  rome format --write npm/app/package.json
  git commit -am $'chore: bump version to ($version)'
  git tag -am $'chore: bump version to ($version)' $'v($version)'
  git push --follow-tags
}
