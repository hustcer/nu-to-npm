
## Publish Nushell to the NPM Registry

The only purpose of this repository is to publish [Nushell](https://github.com/nushell/nushell) officially released binaries to the `NPM` registry as is, for easy installation via `npm`.

For issues about the `nushell` **npm** package (such as installation, format, etc.) please create an issue [here](https://github.com/hustcer/nu-to-npm/issues), and for issues about the `nu` binaries please go to the [Official Nushell Repo](https://github.com/nushell/nushell/issues) to submit an issue.

To install `nu` by npm, simply run: `npm i -g nushell`, then you can run `nu` to start a new session.

## Note

1. If you got some error like 'Error: Couldn't find application binary inside node_modules...' while running `nu` or 'No matching version found for nushell...' while installation, please specify the registry and try to install it again: `npm i -g nushell --registry https://registry.npmjs.com`.
2. The **npm** package for `nushell` currently contains only the `nu` binary, and the official plugins were not included, if you need the full version, please build it from source or [download the packages from here](https://github.com/nushell/nushell/releases)

---

## 将 Nushell 发布到 NPM 仓库

本仓库的唯一作用就是将 [Nushell](https://github.com/nushell/nushell) 官方发布的二进制文件原封不动地发布到 `NPM` 仓库，方便大家通过 `npm` 安装使用。

对于 `nushell` **npm** 包的问题（诸如安装、格式等）可以 [在此](https://github.com/hustcer/nu-to-npm/issues) 提 Issue，至于 `nu` 二进制文件的问题请前往 [此处](https://github.com/nushell/nushell/issues) 提 Issue。

通过 `npm` 安装 **nushell** 只需要执行： `npm i -g nushell` 即可，然后你可以通过 `nu` 命令创建一个新的会话。

## 注意

1. 如果你在运行 `nu` 时看到 'Error: Couldn't find application binary inside node_modules...' 错误，或者在安装过程中看到 'No matching version found for nushell...' 错误，请尝试指定 `registry` 参数并重新安装：`npm i -g nushell --registry https://registry.npmjs.com`。
2. `nushell` 的 **npm** 包内目前只包含 `nu` 二进制文件，不含官方提供的各插件，如需完整版本请自行通过源码构建或者 [由此下载](https://github.com/nushell/nushell/releases)
