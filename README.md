# homebrew-lumos

Homebrew tap for [Lumos](https://github.com/Yoge5h9/Lumos) — a calm, ambient
menu-bar glow for your Claude Code 5-hour usage window. This tap builds Lumos from source on
your machine, so there's no Gatekeeper prompt and no Apple Developer account involved.

> **Status:** pre-release. The formula's `url` / `sha256` are placeholders until the first
> tagged release of Lumos, so `brew install` won't work yet. `brew install --HEAD` can build
> off `main` for testing.

## Install

```sh
brew tap Yoge5h9/lumos
brew install lumos
lumos setup
```

(or in one line: `brew install Yoge5h9/lumos/lumos`)

`lumos setup` wires up your Claude Code status line non-destructively (backed up, wrapped,
never replaced) so Lumos can read your usage data locally. No accounts, no network calls.

## Update

```sh
brew upgrade lumos
```

## Uninstall

```sh
lumos setup --uninstall
brew uninstall lumos
```
