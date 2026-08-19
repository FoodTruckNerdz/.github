# Brand assets

Canonical archive of Food Truck Nerdz round-badge logos and related rasters.

Regenerate PNG / PNG-256 / ICO exports after SVG changes:

```powershell
./assets/scripts/export-brand-rasters.ps1
```

## Revisions

| Folder | Source | Use |
| --- | --- | --- |
| `shaded-production/` | `ftn-site/site-nextjs/public/images/foodtrucknerdz.svg` | **Production** Next.js site (gradients, soft shadow) |
| `flat-illustrator/` | `ftn-site/site-solidstart/public/images/foodtrucknerdz.svg` | Retired SolidStart archive (flat Illustrator export) |
| `shaded-docs/` | `ftn-site/docs/modules/nextjs/images/foodtrucknerdz.svg` | Antora docs copy (minor SVG diff) |
| `illustrator-html-export/` | `ftn-site/docs/modules/nextjs/images/foodtrucknerdz-svg-logo.html` | Reference HTML wrapper (older flat export) |
| `gemini-profile/` | `profile/food-truck-nerdz-gemini-logo.png` | GitHub org profile hero image |

Each revision folder contains:

- `foodtrucknerdz.svg` (or the gemini PNG original)
- `foodtrucknerdz.png` — 500×500
- `foodtrucknerdz-256.png` — 256×256
- `foodtrucknerdz.ico` — multi-size icon (256…16)
- `SOURCE.txt` — provenance

The export script also copies the matching revision into each site package’s `public/images/` and refreshes Next.js favicon files from `shaded-production`:

- `site-nextjs/app/favicon.ico` — multi-size ICO (16–256)
- `site-nextjs/app/icon.png` — 32×32 tab icon
- `site-nextjs/app/apple-icon.png` — 180×180 Apple touch icon
- `site-nextjs/public/favicon.ico` — legacy `/favicon.ico` fallback

## Wordmark

Header/homepage **FTN** / **FoodTruckNerdz** text is not stored here — it is rendered live with the Nabla COLRv1 font in `ftn-site/site-nextjs/components/brand/wordmark.tsx`.

## Credit

Round badge artwork: Diana Montero.
