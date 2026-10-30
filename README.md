# herdr-omarchy-theme

An `omarchy` theme for the [Herdr](https://herdr.dev) desktop app that always
matches your [Omarchy](https://omarchy.org) theme.

Pick **omarchy** in Herdr's *Settings → Look*. From then on, every
`omarchy theme set` (or a pick in the Omarchy theme menu) recolors Herdr too:
terminals, panels and accent.

## Requirements

- Omarchy 4 or newer
- The Herdr desktop app (`herdr-app`), opened at least once. Tested with 0.1.9.
- `jq`

## Install

```sh
git clone https://github.com/alvaroroco/herdr-omarchy-theme.git
cd herdr-omarchy-theme
./install.sh
```

Then choose **omarchy** in *Settings → Look*, or run:

```sh
herdr-app do app.theme --name omarchy
```

## How it works

`install.sh` copies one script, `herdr-omarchy-theme`, into
`~/.config/omarchy/hooks/theme-set.d/`, so Omarchy runs it after every theme
change. The script:

1. Reads the active palette with `omarchy-theme-color`, which also resolves
   older themes that only define `color0..15`.
2. Writes it to `~/.config/herdr-app/themes/omarchy.json` (background,
   foreground, selection, cursor, the 16 ANSI colors and the accent). Herdr
   derives its panel colors from these.
3. If the Herdr window is showing the omarchy theme, picks it again so Herdr
   loads the new file.

Herdr reads a theme file when the theme is picked, not when the file changes,
and picking the theme it already shows keeps the old colors. So step 3 goes
through Herdr's own preset of the same lightness (`graphite` for dark themes,
`paper` for light ones) and back to `omarchy`, which can show as a brief
flicker. If the window is closed, or shows another theme, the script only
updates the file.

`HERDR_APP_HOME` is respected if you moved Herdr's home.

## Uninstall

```sh
./uninstall.sh
```

Removes the hook and `themes/omarchy.json`. If Herdr was showing omarchy, it
switches back to Herdr's default `graphite` / `paper` first.

## Development

```sh
tests/run.sh
```

The tests replace `omarchy-theme-color` and `herdr-app` with the doubles in
`tests/stubs`, so they run anywhere with bash and jq. The fixtures in
`tests/fixtures` are palettes the real `omarchy-theme-color` resolved for a
dark and a light theme.

## License

MIT
