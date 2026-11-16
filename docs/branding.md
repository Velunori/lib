# Velunori identity

The **Pryzmat** mark is the selected direction 03: three separated geometric
planes forming a compact prism. Transparent channels keep the silhouette
clear at the launcher's 18 px size, in every accent and on light backgrounds.

The wordmark is **Velunori**, title case in a regular serif face. The contrast
between the geometric mark and editorial typography is intentional. The
export uses Nimbus Roman with Liberation Serif and generic serif fallbacks,
so it remains editable without embedding or redistributing a font.
Interface labels keep the shell font for readability.


## Files

- `kit/Brand.js`: the single vector definition.
- `kit/BrandMark.qml`: a themeable, transparent icon without an icon-font dependency.
- `assets/brand/velunori-mark-{lavender,mint,pearl,white,graphite}.svg`: portable marks.
- `assets/brand/velunori-wordmark.svg`: horizontal mark and wordmark, for dark surfaces.
- `docs/branding.png`: rendered identity sheet, including the actual 18 px launcher.

Run `node lib/scripts/export-brand.mjs` after changing the vector source.
Render the identity sheet with
`VELUNORI_PREVIEW_PATH="$PWD/lib/docs/branding.png" bash lib/scripts/check.sh`
from the workspace root.

## Usage

Use the mark at 18 px in the menu launcher and 24 px or larger for other UI.
Leave at least 4 units of space around its 24-unit canvas. Avoid frames,
gradients, stretched proportions or extra outlines around the mark. Use one
color at a time; the menu follows the saved or previewed Velunori accent.

Lavender `#c4aff1` is the primary brand color. Mint `#a0ddbf` and Pearl `#e8dfd1`
are supported UI accents. Surfaces stay graphite `#202026`, with text `#eeedf3`.
The white and graphite exports are for neutral dark and light backgrounds.

```qml
import "../lib/kit" as V
V.BrandMark { width: 18; height: 18; ink: theme.accent }
```

The launcher retains its existing left-click menu and right-click terminal
actions and the bar's tooltip and keyboard activation contract.
