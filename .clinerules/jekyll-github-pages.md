# SCITEKNO Site — Development Rules (Jekyll + GitHub Pages)

## Build & preview

- Always use Bundler: `bundle install`, then
  `bundle exec jekyll serve --livereload --host 0.0.0.0 --port 4000` (port 4000 forwarded).
- Never run `jekyll`/`gem` with `sudo`; use the devcontainer.
- Do not hand-edit `Gemfile.lock`; regenerate via `bundle install`/`bundle update`.
- After any plugin/routing/i18n change, **restart the server from a clean build**: stop the
  running server, then run `rm -rf _site` before
  `bundle exec jekyll serve --livereload --host 0.0.0.0 --port 4000`.
  Watch-mode regeneration does NOT delete orphaned files from `_site`, so stale output can
  linger and produce wrong URLs or directory listings instead of the page.

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
- Pages live in root; keep markdown content in `.md` files with front matter and
  let Jekyll render it.
- Use `{% include %}` for header/footer/nav; avoid duplicating markup.
- Put reusable CSS in `assets/css/main.scss` or the layout, NOT inline per page.

## Experiments live on separate git branches

- Site redesign experiments are developed on their own git branches. When an experiment is
  finished it is merged into `main`. There is no longer an in-repo sandbox/experiment
  directory structure — all work happens directly against the site source on a branch.

## i18n — data-driven, plugin-free (HARD CONSTRAINT)

- All user-facing copy lives in `_data/locales/**/*.yml`, keyed by stable string IDs. Never
  hardcode user-facing text in templates/pages.
- Templates resolve the locale catalog, then `{{ t.key }}`:
  - Catalog:
    `{% assign t = site.data.locales[page.lang] | default: site.data.locales[site.default_lang] %}`
- Per-language routing via front matter:
  - `index.md` → `lang: en`, `permalink: /`
  - `index.pt-BR.md` → `lang: pt-BR`, `permalink: /pt-BR/`
- `title`/`description` stay in each page's front matter (they vary per page); do NOT put
  them in `_data/locales/*.yml`.
- Keep a visible language switcher (`_includes/lang-switcher.html`, included by the footer)
  and set `<html lang="{{ page.lang | default: site.lang | default: 'en' }}">`.
- The switcher uses plain Liquid (`site.languages`, `site.default_lang`, `page.lang`) —
  never Polyglot tags such as `static_href` or `{% I18n_Headers %}`.
- All permalinks in `<a href>` attributes must be language-aware. Never hardcode a path that
  omits the `page.lang` conditional. Every internal link in templates, partials, and pages must
  resolve to the correct language subtree (e.g. `/` for en, `/pt-BR/` for pt-BR).
  Pattern: `href="/{% if page.lang == 'pt-BR' %}pt-BR/{% endif %}..."`.
  When validating pages, switching language must keep all navbar, footer, and content links
  inside the current language subtree. If any link points to the wrong language subtree after
  a language switch, that is a regression.

## Content & i18n copy

- User-facing copy defaults to English with PT-BR translation; Brazilian legal entity in footer.
- Keep `contact@scitekno.com.br` consistent everywhere.
- Translation catalogs live under `_data/locales/`, one file per language:
    `_data/locales/{en,pt-BR}.yml`            (top level)
  Keep the two language files in sync. Before committing, run
  `ruby scripts/check-locales` to verify key parity between languages.

## Assets & links

- Use relative URLs / `{{ site.baseurl }}` so links work under any baseurl or language subpath.
- Keep Google Fonts `<link>` in the layout `<head>`.
- Respect `prefers-reduced-motion` for animations.
- When adding centered content blocks (animations, widgets, hero elements), always use explicit
  centering: `margin: X auto Y` for block elements, or Bootstrap utilities like
  `justify-content-center` / `text-center`. Do not rely on parent container alignment alone
  for signature/centered elements. Verify centering visually when adding new block-level elements
  with constrained widths.

## Quality / checks

- Validate YAML (`_config.yml`, `_data/*.yml`) and front matter before committing.
- `bundle exec jekyll build` must be clean (no errors/warnings) before pushing.
- `markdownlint` on `.md` files (extension installed in devcontainer).
- Run `ruby scripts/check-locales` to confirm locale key parity (`_data/locales/{en,pt-BR}.yml`).
- **Before finishing ANY task**, keep markdown warning-free (the VS Code Problems tab must
  show no markdownlint issues in edited files). Run `ruby scripts/lint-markdown` to check, or
  `ruby scripts/lint-markdown --fix` to auto-fix trailing whitespace / blank-line issues, then
  re-run to confirm it exits 0. This mirrors `.markdownlint.json` (MD009/MD012/MD013/MD022/MD032)
  so the CLI check and the editor agree. Excludes `_site`, `.git`, and `.kilo/`.

## Secrets & git

- Never commit secrets/API keys; SSH keys come from the mounted volume.
- Do not commit generated `_site/` (already in `.gitignore`).

## Mobile / Desktop support

- The site must work on mobile and desktop, with components such as navbars being collapsible on mobile.
