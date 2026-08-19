# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] — 2026-08-19

### Fixed

- The arrow's `fill`/`stroke` now inherit from the panel via presentation
  attributes on the SVG element instead of a rule in the optional
  `floating-ember/styles/floating.css`. Previously, `@arrowStrokeWidth` had
  no visible effect unless that stylesheet was imported, because the
  browser's default SVG styles silently blocked plain CSS inheritance.
  `floating.css` is now needed only for `<Popover @modal={{true}}>`'s scrim,
  matching what the docs already claimed.

### Changed

- `arrowStrokeWidth` now defaults to `1` (was `0`), so an arrow shows a
  border out of the box when the panel sets a `stroke` color. Pass `0` for
  a borderless arrow.

## [0.1.2] — 2026-08-15

First release published from GitHub Actions via npm trusted publishing (OIDC).

### Fixed

- Release workflow no longer fails after `pnpm pack` when `tar | head` hits `SIGPIPE` under `pipefail`.

`0.1.1` was tagged to test that pipeline and never reached the registry.

## [0.1.0] — 2026-08-15

Initial release.

### Added

- `<Tooltip>` and `{{tooltip}}` — hover/focus, `role="tooltip"`, non-interactive content
- `<Popover>` — click to open, `role="dialog"`, focus trap, click-outside, optional `@modal` scrim
- `<TooltipGroup>` — shared hover delay across a toolbar
- SVG pointer arrow (`@arrow` / `arrow=true`) with `arrowWidth`, `arrowHeight`, `arrowTipRadius`, `arrowStrokeWidth`
- Positioning via `@floating-ui/dom` (`offset`, `flip`, `shift`, `hide`)
- Named blocks `<:trigger>` / `<:content>`; tagless (no wrapper around the trigger)
- Portal to `document.body` (`@container`, `@renderInPlace`)
- Controlled mode (`@open` / `@onOpenChange`)
- Headless styling via `contentClass`; optional `floating-ember/styles/floating.css` for the modal scrim only
- Published TypeScript declarations for GTS consumers
- Test helpers: `openTooltip`, `closeTooltip`, `openPopover`, `closePopover`
- Ember 6+; CI on Chrome and Firefox, plus embroider-try scenarios

[0.2.0]: https://github.com/ultish/floating-ember/releases/tag/v0.2.0
[0.1.2]: https://github.com/ultish/floating-ember/releases/tag/v0.1.2
