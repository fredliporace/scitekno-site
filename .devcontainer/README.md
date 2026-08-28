# Devcontainer

## Manual jekyll start

```bash
.devcontainer/post-start.sh
```

```bash
.devcontainer/start-jekyll.sh
```

Check logs:

```bash
tail -f /tmp/jekyll.log
```

Stop Jekyll:

```bash
kill $(cat /tmp/jekyll.pid 2>/dev/null || true)
```

## Timelapses

The Timelapses area is data-driven so content can grow without touching templates.

### How it is structured

- `_data/timelapses.yml` — the single source of truth for the index. A flat list of
  items, each with:
  - `copy_id`: stable id used to derive the locale keys (`timelapses_<copy_id>_title` / `_desc`).
  - `section`: underscore id used for grouping and as the section-title locale-key suffix
    (e.g. `mining` → `timelapses_section_mining_title`).
  - `section_slug`: URL path segment for the section (may contain hyphens).
  - `slug`: URL path segment for the item.
  - `type` / `asset`: render type and path to the holomap iframe asset.
  The index groups items by `section` automatically.
- `_data/locales/{en,pt-BR}.yml` — per-item copy (`timelapses_<copy_id>_title` and
  `timelapses_<copy_id>_desc`) and section headings (`timelapses_section_<section>_title`).
  Keep both languages in sync.
- `_includes/timelapses-content.html` — renders the index (sections + cards linking to
  detail pages). Uses the `check-locales` data-driven idiom, so do not rename the
  `copy_id`/`_title`/`_desc` keys without updating the script.
- `_includes/timelapse-detail.html` — shared include for a single timelapse detail page
  (hero, iframe, localized copy, back link).
- Detail pages: `timelapses/<section_slug>/<slug>.md` (en) and the `.pt-BR.md` twin, each
  with `timelapse_id: <copy_id>` and a permalink matching
  `/timelapses/<section_slug>/<slug>/` (and `/pt-BR/...`).

### Adding or updating a timelapse

1. Add/adjust the item in `_data/timelapses.yml` (and a `section` entry if it is new).
2. Add the matching `timelapses_<copy_id>_title` / `_desc` keys in both locale files, plus a
   `timelapses_section_<section>_title` key if the section is new.
3. Create the detail page(s): `timelapses/<section_slug>/<slug>.md` and its `.pt-BR.md` twin,
   setting `timelapse_id` to the item's `copy_id`.
4. Run `ruby scripts/check-locales` to confirm key parity, then
   `bundle exec jekyll build` (clean build: `rm -rf _site` first after routing/data changes).

### Holomap assets

A timelapse detail page embeds a Panel/HoloMap HTML export via an `<iframe>` (the item's
`asset` path). The raw export ships with a light UI that clashes with the dark site theme,
so it must be post-processed before publishing. The expected presentation fixes are:

- Dark background + text color on `<html>`/`<body>` (`#0A1120` / `#EAF0FB`).
- Dark Bokeh toolbar background (`#0A1120`).
- A shadow-DOM style fix (`data-scitekno-fix`) that recolors the Bokeh slider, polled until
  the widgets mount. This was first applied to `assets/holomaps/brumadinho_cb4_pan10.html`.

Apply these automatically with the `prepare-holomap` script (idempotent — safe to re-run):

```bash
ruby scripts/prepare-holomap <exported.html> assets/holomaps/<copy_id>_cb4_pan10.html
```

For example, from the Arena da Baixada export:

```bash
ruby scripts/prepare-holomap video_holomap_pansharpened.html assets/holomaps/arena_baixada_cb4_pan10.html
```

Then point the item's `asset` in `_data/timelapses.yml` at the generated file
(e.g. `assets/holomaps/arena_baixada_cb4_pan10.html`) and rebuild. The exported source
files are not versioned — they are only the format you receive when adding a new timelapse.
