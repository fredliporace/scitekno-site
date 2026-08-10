# SCITEKNO Site — Development Rules (Jekyll + GitHub Pages)

## Build & preview

- Always use Bundler: `bundle install`, then
  `bundle exec jekyll serve --livereload --host 0.0.0.0 --port 4000` (port 4000 forwarded).
- Never run `jekyll`/`gem` with `sudo`; use the devcontainer.
- Do not hand-edit `Gemfile.lock`; regenerate via `bundle install`/`bundle update`.
- After any plugin/routing/migration change (e.g. swapping the i18n approach, adding the pt-BR
  route), **restart the server from a clean build**: stop the running server, then run
  `rm -rf _site` before `bundle exec jekyll serve --livereload --host 0.0.0.0 --port 4000`.
  Watch-mode regeneration does NOT delete orphaned files from `_site`, so stale output (e.g.
  leftover localized subdirs from an old i18n setup) can linger and produce wrong URLs or
  directory listings instead of the page.

## GitHub Pages / deploy constraints

- This site deploys via **native GitHub Pages push-to-deploy** (no Actions workflow).
  Settings → Pages → Build and deployment → Source: **Deploy from a branch** → `main` → `/root`.
- The `CNAME` file at the repo root sets the custom domain `scitekno.com.br`; with a custom
  domain `baseurl` is normally `""` unless the site is later served from a subpath.
- Only the `github-pages` gem is used (Jekyll pinned to 3.10.0). **Do NOT add plugins that
  GitHub Pages does not allow-list** — the native build cannot load them.
- To reproduce production output locally, run `bundle exec jekyll build` after a clean
  `bundle install`; keep the local Gemfile in sync with what GitHub Pages provides so local
  and deployed environments match (this avoids `Liquid syntax error: Unknown tag` failures).

## Source organization (Jekyll conventions)

- Pages in root or `_pages/`; layouts in `_layouts/`, partials in `_includes/`,
  structured data in `_data/` (`.yml`/`.yaml`).
- Use `{% include %}` for header/footer/nav; avoid duplicating markup.
- Put reusable CSS in `assets/css/main.scss` or the layout, NOT inline per page.
- Keep markdown content in `.md` files with front matter; let Jekyll render it.

## i18n — data-driven, plugin-free (HARD CONSTRAINT)

- All user-facing copy lives in `_data/locales/*.yml` — one file per language (`en.yml`,
  `pt-BR.yml`), keyed by stable string IDs. This is the single "strings file" to edit for
  translations.
- Templates read copy via
  `{% assign t = site.data.locales[page.lang] | default: site.data.locales[site.default_lang] %}`
  then `{{ t.key }}`. Never hardcode user-facing text in templates/pages.
- Per-language routing via front matter:
  - `index.md` → `lang: en`, `permalink: /`
  - `index.pt-BR.md` → `lang: pt-BR`, `permalink: /pt-BR/`
- `title`/`description` stay in each page's front matter (they vary per page); do NOT put
  them in `_data/locales/*.yml`.
- Keep a visible language switcher (`_includes/lang-switcher.html`, included by the footer)
  and set `<html lang="{{ page.lang | default: site.lang | default: 'en' }}">`.
- The switcher uses plain Liquid (`site.languages`, `site.default_lang`, `page.lang`) —
  never Polyglot tags such as `static_href` or `{% I18n_Headers %}`.

## Content & i18n copy

- User-facing copy defaults to English with PT-BR translation; Brazilian legal entity in footer.
- Keep `contact@scitekno.com.br` consistent everywhere.
- Keep the two locale files in sync. Before committing, run `ruby scripts/check-locales`
  to verify key parity between languages.

## Assets & links

- Use relative URLs / `{{ site.baseurl }}` so links work under any baseurl or language subpath.
- Keep Google Fonts `<link>` in the layout `<head>`.
- Respect `prefers-reduced-motion` for animations (already present in coming-soon CSS).

## Quality / checks

- Validate YAML (`_config.yml`, `_data/*.yml`) and front matter before committing.
- `bundle exec jekyll build` must be clean (no errors/warnings) before pushing.
- `markdownlint` on `.md` files (extension installed in devcontainer).
- Run `ruby scripts/check-locales` to confirm locale key parity.
- **Before finishing ANY task**, keep markdown warning-free (the VS Code Problems tab must
  show no markdownlint issues in edited files). Run `ruby scripts/lint-markdown` to check, or
  `ruby scripts/lint-markdown --fix` to auto-fix trailing whitespace / blank-line issues, then
  re-run to confirm it exits 0. This mirrors `.markdownlint.json` (MD009/MD012/MD013/MD022/MD032)
  so the CLI check and the editor agree. Excludes `_site`, `.git`, and `.kilo/`.

## Secrets & git

- Never commit secrets/API keys; SSH keys come from the mounted volume.
- Do not commit generated `_site/` (already in `.gitignore`).

## Mobile / Desktop support

- The site must work on mobile and desktop, with components such as navbars being collapsible
  on mobile.