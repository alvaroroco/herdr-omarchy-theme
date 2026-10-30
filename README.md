# Omarchy theme for Herdr

A [Herdr](https://herdr.dev) mod that keeps Herdr in your
[Omarchy](https://omarchy.org) theme: an `omarchy` theme in Settings → Look,
rewritten from the active Omarchy palette on every `omarchy theme set`, and a
small floating pill showing the palette and whether Herdr follows it.

![Omarchy theme](preview.png)

## Install

Needs Omarchy 4+ and the Herdr desktop app, open.

Ask your agent:

> Add the Herdr mod at https://github.com/alvaroroco/herdr-omarchy-theme,
> then run `herdr-app do mod.open --name omarchy-theme` and
> `herdr-app do app.theme --name omarchy`.

Or run it yourself:

```sh
d=~/.config/herdr-app/mods/omarchy-theme
u=https://raw.githubusercontent.com/alvaroroco/herdr-omarchy-theme/main/mods/omarchy-theme
mkdir -p "$d" && curl -fsSL "$u/main.js" -o "$d/main.js" && curl -fsSL "$u/mod.json" -o "$d/mod.json" &&
  herdr-app check "$d" && herdr-app do mod.open --name omarchy-theme && herdr-app do app.theme --name omarchy
```

This downloads the two files, checks them, opens the pill and switches Herdr
to the `omarchy` theme. Run it again to update. The pill reopens on every
start; `×` closes it and stops the syncing.

The mod runs `omarchy-theme-color`, reads Omarchy's state in
`~/.local/state/omarchy/current` and Herdr's `layouts/.state/`, and writes
`~/.config/herdr-app/themes/omarchy.json`. It makes no network requests.

[RECIPE.md](RECIPE.md) is the brief to build it from scratch. The earlier
version, an Omarchy theme-set hook, is tagged
[`v1-hook`](https://github.com/alvaroroco/herdr-omarchy-theme/tree/v1-hook).

## Contributing

Issues are welcome; code changes come in as pull requests. See
[CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT
