set shell := ['nu', '-m', 'light', '-c']

# The export setting causes all just variables
# to be exported as environment variables.

set export := true

JUST_FILE_PATH := justfile()

# Just commands aliases
# alias d := dev
# alias b := build

# 默认显示所有可用命令
default:
  @just --list --list-prefix "··· "

bump-ver version:
  #!/usr/bin/env nu

  let version = $'{{version}}'
  if $version == '' {
    print $'Usage: just bump-ver version=1.0.0'
    exit --now
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

# 扫描代码中的拼写错误, 需要本机安装 `typos-cli`, 使用：`just typos` or `just typos raw`
typos output=('table'):
  #!/usr/bin/env nu

  let output = '{{output}}'
  if not (which typos | length) > 0 {
    print $'(ansi y)[WARN]: (ansi reset)`Typos` not installed, please install it by running `brew install typos-cli`...'
    exit --now
  }
  if $output != 'table' { typos .; exit --now }
  typos . --format brief
    | lines
    | split column :
    | rename file line column correction
    | sort-by correction
    | update line {|l| $'(ansi pb)($l.line)(ansi reset)' }
    | update column {|l| $'(ansi pb)($l.column)(ansi reset)' }
    | upsert author {|l|
        let line = ($l.line | ansi strip)
        git blame $l.file -L $'($line),($line)' --porcelain | lines | get 1 | str replace 'author ' ''
      }
    | move author --before correction

# 检查过期依赖，可以指定应用(`scm`)或者不指定则检查所有应用
outdated:
  cd npm/app; ncu

