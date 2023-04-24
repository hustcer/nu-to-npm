#!/usr/bin/env nu

# TODO:
#   - [√] Check if the tag of the specified version already exists in local git repository

use common.nu [has-ref]

def main [version: string, distTag: string = 'latest'] {

  if not ($version | str replace '^(\d+\.)?(\d+\.)?(\*|\d+)$' '' -a | is-empty) {
    print $'(ansi r)Invalid version number: ($version)(ansi reset)'
    exit --now 1
  }

  if (has-ref $'v($version)') {
    print $'(ansi r)The tag of the specified version already exists: ($version)(ansi reset)'
    exit --now 1
  }

  let file = 'npm/app/package.json'
  $file
    | open
    | update version $version
    | update distTag $distTag
    | update optionalDependencies {|it| ($it.optionalDependencies | transpose k v | update v $version | transpose -r | into record) }
    | save -f $file

  rome format --indent-size 2 --quote-style single --indent-style space --write npm/app
  rome format --indent-size 2 --indent-style space --write npm/app/package.json
  git commit -am $'chore: bump version to ($version)'
  git tag -am $'chore: bump version to ($version)' $'v($version)'
  git push --follow-tags
}
