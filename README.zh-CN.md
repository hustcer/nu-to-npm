
## 将 Nushell 发布到 NPM 仓库

本仓库的唯一作用就是将 [Nushell](https://github.com/nushell/nushell) 官方发布的二进制文件原封不动地发布到 `NPM` 仓库，方便大家通过 `npm` 安装使用。

对于 `nushell` **npm** 包的问题（诸如安装、格式等）可以 [在此](https://github.com/hustcer/nu-to-npm/issues) 提 Issue，至于 `nu` 二进制文件的问题请前往 [此处](https://github.com/nushell/nushell/issues) 提 Issue。

通过 `npm` 安装 **nushell** 只需要执行： `npm i -g nushell` 即可，然后你可以通过 `nu` 命令创建一个新的会话。

## 注意

`nushell` 的 **npm** 包内目前只包含 `nu` 二进制文件，不含官方提供的各插件，如需完整版本请自行通过源码构建或者 [由此下载](https://github.com/nushell/nushell/releases)
