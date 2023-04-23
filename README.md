
## Publish Nushell to the NPM Registry

The only purpose of this repository is to publish [Nushell](https://github.com/nushell/nushell) officially released binaries to the `NPM` registry as is, for easy installation via `npm`.

For issues about the `nushell` **npm** package (such as installation, format, etc.) please create an issue [here](https://github.com/hustcer/nu-to-npm/issues), and for issues about the `nu` binaries please go to the [Official Nushell Repo](https://github.com/nushell/nushell/issues) to submit an issue.

To install `nu` by npm, simply run: `npm i -g nushell`, then you can run `nu` to start a new session.

## Note

If you got some error like 'Error: Couldn't find application binary inside node_modules...' while running `nu` or 'No matching version found for nushell...' while installation, please specify the registry and try to install it again: `npm i -g nushell --registry https://registry.npmjs.com`.

The **npm** package for `nushell` currently contains only the `nu` binary, and the official plugins were not included, if you need the full version, please build it from source or [download the packages from here](https://github.com/nushell/nushell/releases)

