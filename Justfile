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

# 更新仓库里所有 nushell 相关包的 npm 版本号，创建 git tag 并推送到远程仓库
bump-ver version:
  @nu nu/bump-ver.nu {{version}}

# 扫描代码中的拼写错误, 需要本机安装 `typos-cli`, 使用：`just typos` or `just typos raw`
typos output=('table'):
  @nu nu/typos.nu {{output}}

# 检查过期 Node Modules 依赖
outdated:
  cd npm/app; ncu

