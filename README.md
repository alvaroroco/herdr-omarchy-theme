# Omarchy theme for Herdr

A [Herdr](https://herdr.dev) mod that keeps Herdr in your
[Omarchy](https://omarchy.org) theme: an `omarchy` theme in Settings → Look,
rewritten from the active Omarchy palette on every `omarchy theme set`, and a
small floating pill showing the palette and whether Herdr follows it.

![Omarchy theme](preview.png)

## Install

Needs Omarchy 4+ and the Herdr desktop app.

```sh
git clone https://github.com/alvaroroco/herdr-omarchy-theme.git
cp -r herdr-omarchy-theme/mods/omarchy-theme ~/.config/herdr-app/mods/
herdr-app check ~/.config/herdr-app/mods/omarchy-theme
herdr-app do mod.open --name omarchy-theme
```

Then pick **omarchy** in Settings → Look (or click `use` on the pill). The
pill reopens on every start; `×` closes it and stops the syncing.

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
