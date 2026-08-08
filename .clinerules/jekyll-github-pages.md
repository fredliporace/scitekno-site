# SCITEKNO Site — Development Rules (Jekyll + GitHub Pages)

## Build & preview
- Always use Bundler: `bundle install`, then
  `bundle exec jekyll serve --livereload --host 0.0.0.0 --port 4000` (port 4000 forwarded).
- Never run `jekyll`/`gem` with `sudo`; use the devcontainer.
- Do not hand-edit `Gemfile.lock`; regenerate via `bundle install`/`bundle update`.

## GitHub Pages / deploy constraints
- This site uses **Polyglot + GitHub Actions** for deployment. Native GitHub Pages push-to-deploy
  is disabled. Do NOT rely on it.
- Keep `_config.yml` valid YAML; set `title`, `description`, `url`, `baseurl`.
  With custom domain `CNAME` = scitekno.com.br, `baseurl` is normally `""` unless served from a subpath.
- Test locally (`bundle exec jekyll build`) with no warnings/errors before pushing.

## Source organization (Jekyll conventions)
- Pages in root or `_pages/`; layouts in `_layouts/`, partials in `_includes/`,
  structured data in `_data/` (`.yml`/`.yaml`).
- Use `{% include %}` for header/footer/nav; avoid duplicating markup.
- Put reusable CSS in `assets/css/main.scss` or the layout, NOT inline per page.
  The current `index.html` keeps CSS inline only as a temporary coming-soon page.
- Keep markdown content in `.md` files with front matter; let Jekyll render it.

## Home page — output parity (HARD CONSTRAINT)
- The existing `index.html` (236 lines, hand-written coming-soon page) is the **reference output**.
  Its content and structure must not change.
- The Jekyll source (`index.md` + `_layouts/default.html` + `_includes/*`) must render to
  `_site/index.html` that is **structurally and visually identical** to the reference `index.html`.
  In other words: `index.md` is built "backwards" — the Jekyll pipeline's job is to reproduce the
  current static page exactly, then grow from there.
- Migration order (must preserve output at each step):
  1. Start with the reference `index.html` as the correctness baseline.
  2. Extract the shared shell (doctype, `<head>` with fonts, `<body>` open/close, `<footer>`) into
     `_layouts/default.html` and `_includes/header.html` / `_includes/footer.html`.
  3. Move the inline `<style>` block into `assets/css/main.scss` (or keep in layout `<head>` if
     scoped to this page only); update the layout to load it.
  4. Create `index.md` with front matter `layout: default` and the `<main>` content from the
     reference page.
  5. Run `bundle exec jekyll build` and diff `_site/index.html` against the reference `index.html`.
     The diff must be empty (or limited to insignificant whitespace/quoting). Do not proceed until
     parity is confirmed.
  6. Once parity is confirmed, the reference `index.html` may be removed or kept as a snapshot;
     the Jekyll-rendered version is canonical.
- Do NOT leave a hand-written `index.html` alongside a Jekyll-rendered one after migration — that
  causes ambiguity about which is canonical.

## Multilingual (i18n)
- Supported languages: English (default) and Portuguese (pt-BR). Contact: contact@scitekno.com.br.
- This site uses **jekyll-polyglot** for i18n. It is configured in `_config.yml` with
  `languages: [en, pt-BR]`, `default_lang: en`,
  `exclude_from_localization: [assets, images, css, CNAME]`.
- Deploy via `.github/workflows/deploy.yml` running `bundle exec jekyll build` and publishing
  `_site/` (e.g. `peaceiris/actions-gh-pages@v3`). Native Pages push-to-deploy will NOT run Polyglot.
- Use Polyglot's `{% I18n_Headers %}` and language switcher; do not manually rewrite localized URLs.
- Polyglot is theme-agnostic: the Jekyll theme/template may be chosen later. When a theme is
  selected, build the language switcher in `_includes`/layout (or use the theme's if it has one).
  Never combine Polyglot with a second i18n system.
- FORBIDDEN: enabling any multilingual plugin while still relying on the native GitHub Pages build.
- Always provide a visible language switcher and respect `lang`/`hreflang` for SEO.

## Content & i18n copy
- User-facing copy defaults to English with PT-BR translation; Brazilian legal entity in footer.
- Keep `contact@scitekno.com.br` consistent everywhere.

## Assets & links
- Use relative URLs / `{{ site.baseurl }}` so links work under any baseurl or language subpath.
- Keep Google Fonts `<link>` in the layout `<head>` if moving off inline `index.html`.
- Respect `prefers-reduced-motion` for animations (already present in coming-soon CSS).

## Quality / checks
- Validate YAML (`_config.yml`, `_data/*.yml`) and front matter before committing.
- `bundle exec jekyll build` must be clean (no errors/warnings) before pushing.
- `markdownlint` on `.md` files (extension installed in devcontainer).
- Verify the Actions workflow builds and deploys `_site/` successfully.

## Secrets & git
- Never commit secrets/API keys; SSH keys come from the mounted volume.
- Do not commit generated `_site/` (add to `.gitignore` if missing).
