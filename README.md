
## Publish Nushell to the NPM Registry

The only purpose of this repository is to publish [Nushell](https://github.com/nushell/nushell) officially released binaries to the `NPM` registry as is, for easy installation via `npm`.

For issues about the `nushell` **npm** package (such as installation, format, etc.) please create an issue [here](https://github.com/hustcer/nu-to-npm/issues), and for issues about the `nu` binaries please go to the [Official Nushell Repo](https://github.com/nushell/nushell/issues) to submit an issue.

To install `nu` by npm, simply run: `npm i -g nushell`, then you can run `nu` to start a new session.

## Note

1. If you got some error like 'Error: Couldn't find application binary inside node_modules...' while running `nu` or 'No matching version found for nushell...' while installation, please specify the registry and try to install it again: `npm i -g nushell --registry https://registry.npmjs.com`.
2. The **npm** package for `nushell` currently contains only the `nu` binary, and the official plugins were not included, if you need the full version, please build it from source or [download the packages from here](https://github.com/nushell/nushell/releases)

## FAQ

1. Why is `Nushell` be published to `npm` even? There's nothing JavaScript about Nushell (that I know of?), Isn't npm...for js packages?

    The direct cause of publishing `Nushell` to `npm` was from `Nushell`'s user feedback: "I'd like to run nu scripts in environments that only have access to npm for installing dependencies.". In fact, we have encountered many times such situation with network limitations too, and publish to `npm` is a good approach.

    Nushell's philosophy is to behave consistently across platforms, It will be much better that the nu users can install it in a cross platform way, especially for a container environment that doesn't have `winget` or `brew` installed. Otherwise, they have to select and download the right package (There are already ten packages for different platform and arch, and will have more as the time goes on), unzip it, and add `nu` binaries to the `PATH` env, that's much complicated than just simply run `npm i -g nushell`.

    `npm` may be thought as typically for js packages, however, nowadays lots of binaries written by `rust` or `go` have been published to npm, such as `git-cliff`, `lefthook`, etc. they are all dev tools, and `nushell` is an engine that could power lots of develop involved scripts, and publish it to `npm` will make it easier to access especially for JS related projects, as they already have `npm` been installed.

    Anyway, install `Nushell` by `npm` is just a bonus, there are many other ways, you can choose anyone suitable for you.

1. Will the npm version of `nu` I installed be bloated?

    No. You can read that from the [base npm `package.json`](https://github.com/hustcer/nu-to-npm/blob/main/npm/app/package.json) and the [platform specific `package.json`](https://github.com/hustcer/nu-to-npm/blob/main/npm/package.json.tmpl), only the packages in `dependencies` will be installed, and the dependencies will be installed is **0**, for `optionalDependencies` that means `npm` will choose the exact one package according to your `os` and `cpu` arch. For example, I'm using a mac with Intel cpu inside and `npm` will install only `@nushell/darwin-x64` for me and nothing else. See? `npm` choose the right package for me with just one command.

1. Will the npm version of `nu` I installed has JS performance issue?

    Well, you can read that from the [source here](https://github.com/hustcer/nu-to-npm/blob/main/npm/app/src/index.ts). All node does is simply call the `nu` binary itself, and nothing more.

---

## 将 Nushell 发布到 NPM 仓库

本仓库的唯一作用就是将 [Nushell](https://github.com/nushell/nushell) 官方发布的二进制文件原封不动地发布到 `NPM` 仓库，方便大家通过 `npm` 安装使用。

对于 `nushell` **npm** 包的问题（诸如安装、格式等）可以 [在此](https://github.com/hustcer/nu-to-npm/issues) 提 Issue，至于 `nu` 二进制文件的问题请前往 [官方仓库](https://github.com/nushell/nushell/issues) 提 Issue。

通过 `npm` 安装 **nushell** 只需要执行： `npm i -g nushell` 即可，然后你可以通过 `nu` 命令创建一个新的会话。

## 注意

1. 如果你在运行 `nu` 时看到 'Error: Couldn't find application binary inside node_modules...' 错误，或者在安装过程中看到 'No matching version found for nushell...' 错误，请尝试指定 `registry` 参数并重新安装：`npm i -g nushell --registry https://registry.npmjs.com`。
2. `nushell` 的 **npm** 包内目前只包含 `nu` 二进制文件，不含官方提供的各插件，如需完整版本请自行通过源码构建或者 [由此下载](https://github.com/nushell/nushell/releases)
