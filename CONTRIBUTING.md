# Contributing

Bug reports and ideas are welcome as [issues](https://github.com/alvaroroco/herdr-omarchy-theme/issues).
Code changes come in as pull requests; nobody pushes to `main` directly.

## Reporting a bug

Include:

- your Herdr version (`herdr-app --version`) and Omarchy version (`omarchy version`)
- the Omarchy theme you switched to
- the output of `herdr-app status`
- a screenshot (`herdr-app shot`) if it's about how Herdr looks

## Pull requests

1. Fork the repo and branch from `main`.
2. Keep the change to one thing.
3. If it changes what the mod does or shows, update `RECIPE.md` so a fresh
   build from the recipe matches the files. If it changes the pill, update
   `preview.png` too.
4. Check it in a running Herdr:

   ```sh
   cp -r mods/omarchy-theme ~/.config/herdr-app/mods/
   herdr-app check ~/.config/herdr-app/mods/omarchy-theme
   ```

   then switch themes with `omarchy theme set <name>` and confirm Herdr
   follows.
5. In the PR, say what you tested and paste the `herdr-app check` output.

By contributing you agree your changes are released under the MIT license.
