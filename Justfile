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

# Install all dependencies
i:
  cd npm/app; yarn install

# 该任务支持选项:
#   `--dist-tag` 该选项的值会直接传给 `npm publish --tag`, 默认值为 `latest`
#   `--nu-ver` 该选项用于指定下载和发布到 npm 的 nushell 版本, 默认值与 `version` 相同, 如果指定则会下载指定版本的 nushell 并发布到 npm
# 更新仓库里所有 nushell 相关包的 npm 版本号，创建 git tag 并推送到远程仓库, eg: just bump-ver 0.78.0 --dist-tag latest --nu-ver 0.78.0
bump-ver version *FLAGS:
  @nu nu/bump-ver.nu {{version}} {{FLAGS}}

# 扫描代码中的拼写错误, 需要本机安装 `typos-cli`, 使用：`just typos` or `just typos raw`
typos output=('table'):
  @nu nu/typos.nu {{output}}

# 检查过期 Node Modules 依赖
outdated:
  cd npm/app; ncu

