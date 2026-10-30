import { View, div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { exec, home, appHome, readTextFile, writeTextFile, watchFolder, shared, settings, theme, run, props, closeOverlay } from "herdr";

// Keeps themes/omarchy.json equal to the active Omarchy palette and shows it
// in a small window. Omarchy swaps ~/.local/state/omarchy/current/theme on every
// `omarchy theme set`, so watching that folder catches each change.
const THEME = "omarchy";
const stateDir = () => `${home()}/.local/state/omarchy/current`;
const themeFile = () => `${appHome()}/themes/${THEME}.json`;
const HEX = /^#[0-9a-f]{6}$/i;

// "theme-liftoff" -> "Theme Liftoff", as `omarchy theme current` prints it.
const prettyName = (slug) => slug.trim().replace(/(^|-)([a-z])/g, (_, s, c) => s + c.toUpperCase()).replace(/-/g, " ");

function parsePalette(tsv) {
  const color = {};
  for (const line of tsv.split("\n")) {
    const [key, value] = line.split("\t");
    if (key && value) color[key] = value.trim();
  }
  return color;
}

// The themes/<name>.json format: Herdr derives its panel colors from these.
function renderTheme(c) {
  const keys = ["background", "foreground", "selection_background", "cursor", "accent"];
  for (let i = 0; i < 16; i++) keys.push(`color${i}`);
  const bad = keys.find((k) => !HEX.test(c[k] ?? ""));
  if (bad) throw new Error(`${bad} is not a #rrggbb color: '${c[bad] ?? ""}'`);

  const q = (k) => `"${c[k].toLowerCase()}"`;
  const row = (from) => Array.from({ length: 8 }, (_, i) => q(`color${from + i}`)).join(", ");
  return `{
  "background": ${q("background")},
  "foreground": ${q("foreground")},
  "selection": ${q("selection_background")},
  "cursor": ${q("cursor")},
  "ansi": [
    ${row(0)},
    ${row(8)}
  ],
  "colors": {
    "accent": ${q("accent")}
  }
}
`;
}

// The shown layout's pick (either half), else settings.json's.
async function omarchyIsChosen() {
  const hasIt = (t) => t != null && (typeof t === "object" ? [t.light, t.dark] : [t]).includes(THEME);
  const raw = await readTextFile(`${appHome()}/layouts/.state/${shared("layout") ?? "main"}.json`);
  try {
    const picked = raw && JSON.parse(raw).theme;
    if (picked != null) return hasIt(picked);
  } catch {}
  return hasIt(settings().theme);
}

export default class OmarchyTheme extends View {
  init(_props, cx) {
    this.name = null;
    this.palette = null;
    this.error = null;
    cx.spawn(async (cx) => {
      await this.sync(cx);
      for (;;) {
        await watchFolder(stateDir());
        await this.sync(cx);
      }
    });
  }

  async sync(cx) {
    try {
      const colors = `${stateDir()}/theme/colors.toml`;
      const result = await exec("omarchy-theme-color", ["--file", colors, "--all"]);
      // Mid-switch the theme folder is briefly gone; the next event retries.
      if (result.code !== 0) return;

      const palette = parsePalette(result.stdout);
      const text = renderTheme(palette);
      this.palette = palette;
      this.name = prettyName((await readTextFile(`${stateDir()}/theme.name`)) ?? "");
      this.error = null;

      const old = await readTextFile(themeFile());
      if (old !== text) {
        await writeTextFile(themeFile(), text, old);
        // Herdr loads a theme file when the theme is picked, and picking the
        // shown one again keeps the old colors: go through a preset of the
        // same lightness and back.
        if (await omarchyIsChosen()) {
          run("app.theme", { name: palette.mode === "light" ? "paper" : "graphite" });
          run("app.theme", { name: THEME });
        }
      }
    } catch (e) {
      this.error = e?.code === "ENOENT" || /not found|No such file/i.test(String(e))
        ? "Omarchy not found (needs omarchy-theme-color)"
        : String(e?.message ?? e);
    }
    cx.notify();
  }

  // A small window Herdr keeps over the layout: drag it anywhere; a press on
  // its buttons must not start a drag.
  render() {
    const t = theme();
    const p = this.palette;
    const showing = p && t.background?.toLowerCase() === p.background.toLowerCase();
    const swatches = p
      ? ["accent", "color1", "color2", "color3", "color4", "color5", "color6"].map((k) =>
          div().size(9).rounded(2).bg(p[k]))
      : [];
    const button = (id, label, color, action) => div().id(id).text_color(color)
      .hover((s) => s.text_color(t.foreground))
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click(action)
      .child(label);

    return h_flex().h(28).px(10).gap(8).items_center().text_size(11.8).text_color(t.muted)
      .child(h_flex().gap(3).items_center().children(swatches))
      .child(div().text_color(t.foreground).child(this.name ?? "Omarchy"))
      .when(Boolean(this.error), (el) => el.child(div().max_w(220).truncate().text_color(t.blocked).child(this.error)))
      .when(Boolean(p) && !this.error, (el) => el.child(showing
        ? div().text_color(t.dim).child("synced")
        : button("use", "use", t.accent, () => run("app.theme", { name: THEME }))))
      .child(button("close", "×", t.dim, () => closeOverlay(props().overlay)));
  }
}
