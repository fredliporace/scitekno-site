# Plan: Kilo Code Rules File for SCITEKNO Jekyll Site (incl. multilingual strategy)

## Context
Jekyll static site deployed via GitHub Pages, developed in a Ruby 3.3 devcontainer. Current state:
- `index.html` — hand-written "coming soon" page, all CSS inline in a `<style>` block.
- Empty scaffold: `_config.yml`, `_layouts/default.html`, `_includes/{header,footer,nav}.html`,
  `_data/nav.yml`, `about.md`, `index.md`.
- `Gemfile` pins only the `github-pages` gem (native Pages build, no Actions workflow yet).
- `CNAME` = `scitekno.com.br` (custom domain).
- `.devcontainer/post-create.sh` runs `bundle install`; port 4000 forwarded.
- No `.github/workflows`.

**Decisive constraint for multilingual:** GitHub Pages' native builder only runs its
allow-listed plugins. Neither `jekyll-polyglot` nor `jekyll-multiple-languages-plugin` is
allow-listed, so a plugin-based i18n approach **silently fails** on native Pages (site builds,
no language support). The choice therefore depends on the deploy method.

## Multilingual options — evaluation

### Option A — Plugin (Polyglot) + GitHub Actions deploy  [RECOMMENDED]
- Use `jekyll-polyglot` (gem `jekyll-polyglot`, currently v1.13, actively maintained, first-class
  `pt-BR` support) added to `group :jekyll_plugins` in `Gemfile` and `plugins:` in `_config.yml`
  (`languages: [en, pt-BR]`, `default_lang: en`, `exclude_from_localization: [assets, images, css, CNAME]`).
- **Requires switching off native Pages build** to a Actions workflow that runs
  `bundle exec jekyll build` and deploys `_site/` to `gh-pages` (e.g. `peaceiris/actions-gh-pages@v3`),
  since native Pages ignores the plugin.
- Pros: automatic URL relativization, fallback to default lang, SEO/hreflang, built-in switcher.
- Cons: adds a deploy workflow; loses push-to-deploy simplicity.
- Best when the site will grow and you accept a CI deploy.

### Option B — No-plugin, manual language folders + Liquid data  [KEEP NATIVE DEPLOY]
- Keep current native GitHub Pages build. Store strings in `_data/lang/{en,pt-BR}.yml`, serve `/`
  (default) and `/pt-BR/`, set a `lang` front-matter var per page, filter collections by lang,
  build the switcher with `{{ site.baseurl }}`/`{{ site.default_lang }}`.
- Pros: works with zero-config native Pages; no extra gems/workflow.
- Cons: you hand-roll URL relativization, fallback, sitemaps, and the switcher.
- Best when you want to keep the current dead-simple deploy.

### Option C — Pre-build/static generator script — overkill for now; ignore.

**Decision (user confirmed): Strategy A — Polyglot + GitHub Actions.** The rules file mandates
this. Theme/template can be selected LATER (Polyglot is theme-agnostic; the switcher is additive).
Do not block the rules file on theme choice. If a later theme bundles its own i18n, do not run two
i18n systems (forbidden by rules).

## Goal
Create a rules file that Kilo Code (and other agents) load to follow sound Jekyll + GitHub Pages
development, including the selected multilingual strategy, so future edits stay consistent/deployable.

## Deliverable
Single rules file at `.kilo/rules/jekyll-github-pages.md`
(alternative: root `AGENTS.md`; prefer `.kilo/rules/` so it auto-loads without polluting root).

## Proposed rules content (implementation agent writes this)

```markdown
# SCITEKNO Site — Development Rules (Jekyll + GitHub Pages)

## Build & preview
- Always use Bundler: `bundle install`, then
  `bundle exec jekyll serve --livereload --host 0.0.0.0 --port 4000` (port 4000 forwarded).
- Never run `jekyll`/`gem` with `sudo`; use the devcontainer.
- Do not hand-edit `Gemfile.lock`; regenerate via `bundle install`/`bundle update`.

## GitHub Pages / deploy constraints
- The chosen deploy method dictates plugin support (see Multilingual section).
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

## Multilingual (i18n) — REQUIRED DECISION
- Supported languages: English (default) and Portuguese (pt-BR). Contact: contact@scitekno.com.br.
- Choose ONE strategy and apply it consistently:

  ### Strategy A — Polyglot + GitHub Actions (preferred for growth)
  - Add `gem "jekyll-polyglot"` under `group :jekyll_plugins` in Gemfile; list in `_config.yml`
    `plugins:` with `languages: [en, pt-BR]`, `default_lang: en`,
    `exclude_from_localization: [assets, images, css, CNAME]`.
  - Deploy via `.github/workflows/deploy.yml` running `bundle exec jekyll build` and publishing
    `_site/` (e.g. `peaceiris/actions-gh-pages@v3`). Native Pages push-to-deploy will NOT run Polyglot.
  - Use Polyglot's `{% I18n_Headers %}` and language switcher; do not manually rewrite localized URLs.
  - Polyglot is theme-agnostic: the Jekyll theme/template may be chosen later. When a theme is
    selected, build the language switcher in `_includes`/layout (or use the theme's if it has one).
    Never combine Polyglot with a second i18n system.

  ### Strategy B — No-plugin (keep native Pages)
  - Do NOT add Polyglot/other i18n plugins (native Pages ignores them).
  - Store strings in `_data/lang/{en,pt-BR}.yml`; serve `/` and `/pt-BR/`; set `lang` front matter;
    build switcher with `{{ site.baseurl }}`/`{{ site.default_lang }}`; hand-roll fallback + sitemap.

- FORBIDDEN: enabling a multilingual plugin while still relying on the native GitHub Pages build.
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
- For Strategy A, also verify the Actions workflow builds and deploys `_site/` successfully.

## Secrets & git
- Never commit secrets/API keys; SSH keys come from the mounted volume.
- Do not commit generated `_site/` (add to `.gitignore` if missing).
```

## Implementation steps
1. Create `.kilo/rules/` if missing.
2. Write `.kilo/rules/jekyll-github-pages.md` with the content above (trim to repo conventions).
3. Confirm it references only real repo paths (`index.html`, `_config.yml`, `_layouts/default.html`,
   `_includes/*`, `_data/nav.yml`, `about.md`, `CNAME`, `Gemfile`, `.devcontainer/post-create.sh`).
4. Add `_site/` to `.gitignore` if missing.
5. Home page migration (preserves reference `index.html` output):
   a. Use current `index.html` as correctness baseline.
   b. Extract doctype/`<head>`/`<body>` shell into `_layouts/default.html` and `_includes/header.html`,
      `_includes/footer.html`.
   c. Move inline `<style>` into `assets/css/main.scss` or layout `<head>`.
   d. Create `index.md` with `layout: default` and the `<main>` content.
   e. Run `bundle exec jekyll build` and diff `_site/index.html` against reference `index.html`;
      diff must be empty (or whitespace-only). Do not proceed until parity is confirmed.
   f. Once parity is confirmed, the reference `index.html` may be removed or kept as a snapshot;
      the Jekyll-rendered version is canonical.
6. If Strategy A (Polyglot + Actions) is chosen: add `.github/workflows/deploy.yml` and switch off
   native Pages build.

## Validation
- `bundle exec jekyll build` succeeds after adding the rules file (rules file is not part of build).
- Home page parity: after migration, `diff -u index.html _site/index.html` is empty (or whitespace-only).
- For Strategy A: push triggers Actions and deploys a multilingual `_site/`; verify `/` and `/pt-BR/`.
- For Strategy B: local `jekyll serve` shows both `/` and `/pt-BR/` with correct switcher links.

## Open decisions left to user
- Theme/template: SELECT LATER (not blocking). Polyglot is theme-agnostic; switcher is additive.
- Rules file location: `.kilo/rules/jekyll-github-pages.md` (preferred) vs root `AGENTS.md`.
