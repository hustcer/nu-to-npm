#!/usr/bin/env nu

def main [version: string] {

  if $version == '' {
    print $'Usage: just bump-ver version=1.0.0'
    exit --now 1
  }

  if not ($version | str replace '^(\d+\.)?(\d+\.)?(\*|\d+)$' '' -a | is-empty) {
    print $'(ansi r)Invalid version number: ($version)(ansi reset)'
    exit --now 1
  }

  let file = 'npm/app/package.json'
  open $file
    | update version {|v| $version }
    | update optionalDependencies.@nushell/linux-x64 {|v| $version }
    | update optionalDependencies.@nushell/linux-x64 {|v| $version }
    | update optionalDependencies.@nushell/linux-arm {|v| $version }
    | update optionalDependencies.@nushell/linux-arm64 {|v| $version }
    | update optionalDependencies.@nushell/linux-riscv64 {|v| $version }
    | update optionalDependencies.@nushell/darwin-x64 {|v| $version }
    | update optionalDependencies.@nushell/darwin-arm64 {|v| $version }
    | update optionalDependencies.@nushell/windows-x64 {|v| $version }
    | to json -i 2
    | save -f $file

  rome format --indent-size 2 --quote-style single --indent-style space --write npm/app
  rome format --indent-size 2 --indent-style space --write npm/app/package.json
  git commit -am $'chore: bump version to ($version)'
  git tag -am $'chore: bump version to ($version)' $'v($version)'
  git push --follow-tags
}
