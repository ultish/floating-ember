# Ember Tooltip + Popover v2 Addon

Scaffold a greenfield Ember v2 addon using GTS and Vite. Positioning comes from `@floating-ui/dom`. The addon is headless; Tailwind / DaisyUI examples live only in the test app.

Glint is optional local DX (VS Code / Cursor extension). It is not a runtime dependency.

Publish ordinary TypeScript `.d.ts` (blueprint `declarations/` + `exports.types`) so GTS/TS consumers type-check imports. Do not ship a template-registry or treat Glint as a consumer requirement.

Two public widgets share one private floating core:

- **Tooltip** — hover/focus, rich but **non-interactive** text (line breaks, bold, etc.)
- **Popover** — click to open, **interactive** content (links, buttons, forms)

The 80% tooltip case is an element modifier. The compound named-block API covers rich tooltip markup and all popovers.

Package name: **`floating-ember`**.

## Why this approach

Existing options fall short for modern Ember:

- [ember-tooltips](https://github.com/sir-dunxalot/ember-tooltips) / [ember-attacher](https://github.com/tylerturdenpants/ember-attacher) — v1 addons, classic patterns, not GTS-native
- [ember-velcro](https://github.com/CrowdStrike/ember-velcro) — Floating UI positioning primitive, not a tooltip or popover
- [ember-primitives](https://ember-primitives.pages.dev/) — broader library, not a focused floating-UI package

This repo is empty, so we start from `@ember/addon-blueprint`.

## Key decisions

| Decision | Choice | Why |
|---|---|---|
| Product | Tooltip **and** Popover | Same positioning/portal; opposite content and interaction rules |
| Shared core | Private floating manager + position/portal | Do not fork geometry for the second widget |
| Tooltip content | Rich, non-interactive (`<br>`, `<strong>`, `<em>`) | `role="tooltip"` is a description, not a dialog |
| Popover content | Interactive allowed | Links/buttons need click-to-open + focus management |
| Tooltip 80% API | Element modifier: `<button {{tooltip "…"}}>` | Modern Ember, no wrapper, no parent-element magic |
| Compound API | Named blocks `:trigger` / `:content` | Rich tooltip markup + every popover |
| Trigger attachment | Modifier as `:trigger` block param | No wrapper element around the consumer's control |
| DOM contract | Components are template-only — zero extra nodes around the trigger | Flex/grid and child selectors stay intact |
| Positioning | `@floating-ui/dom` (`computePosition` + `autoUpdate`) | React hooks do not apply |
| Portal | Native `in-element` to `document.body` | Content never participates in parent overflow/layout |
| Types | Publish `.d.ts`; Glint local-only | TS/GTS consumers need declarations; template-registry and consumer Glint setup are not required |
| Styling | Headless | Data attributes + `@contentClass`; Tailwind/DaisyUI only in the test app |
| Public surface | `Tooltip`, `TooltipGroup`, `Popover`, `{{tooltip}}` | Position/trigger modifiers stay private |

## Tooltip vs Popover

These are not two skins of one component. They share geometry. They must not share interaction or ARIA.

| | Tooltip | Popover |
|---|---|---|
| Opens | Hover + focus | Click (toggle) |
| Closes | Mouseleave, blur, Escape | Click outside, click trigger, Escape |
| Delay | Yes (`@delay` / `@closeDelay`, plus `TooltipGroup` delay groups) | No |
| Role | `role="tooltip"` | `role="dialog"` (or documented variant) |
| Trigger ARIA | `aria-describedby` when open | `aria-expanded`, `aria-haspopup`, `aria-controls` |
| Content | Bold, italics, line breaks, inline markup | Links, buttons, fields, any template |
| Pointer events | `pointer-events: none` on the floating node | Normal — pointer must reach the content |
| Focus | Does not move into the floating node | Moves in; trap while open; restore to trigger on close |
| String shortcut | `{{tooltip "…"}}` modifier | None — popovers need a content block |

Do **not** add `@interactive` on `<Tooltip>` to “turn it into a popover.” That is how the two widgets get confused. If the content has a link, the consumer uses `<Popover>`.

### Tooltip content policy

Allowed: text, `<br>`, `<strong>`, `<em>`, `<span>`, `<code>`, lists used as prose.

Not allowed: `a`, `button`, `input`, `select`, `textarea`, `[href]`, `[tabindex]` (except `-1`).

Enforcement:

- CSS `pointer-events: none` on the tooltip node — mouse cannot activate a link even if someone puts one in
- Dev-mode assert: after render, warn if the content contains interactive selectors
- Docs state the rule next to the API, with “use `<Popover>`” as the next sentence

Screen readers still announce whatever is inside `role="tooltip"`. The assert is so we do not silently bless the wrong widget.

## Public API

### Tooltip — string modifier (common case)

```gts
import tooltip from '…/modifiers/tooltip';

<button type="button" {{tooltip "Save your changes"}}>
  Save
</button>
```

Optional named args match the component where they make sense:

```gts
<button type="button" {{tooltip "Save your changes" placement="top" delay=200}}>
  Save
</button>
```

This is an **element modifier** on the tag — not a child component that climbs `parentElement`.

### Tooltip — named blocks (rich, still non-interactive)

```gts
import Tooltip from '…/components/tooltip';

<Tooltip @placement="top" @delay={{200}}>
  <:trigger as |trigger|>
    <button type="button" {{trigger}}>
      Save
    </button>
  </:trigger>

  <:content>
    Saves your changes to the server.
    <br />
    <strong>Cannot be undone.</strong>
  </:content>
</Tooltip>
```

### Popover — named blocks (interactive)

```gts
import Popover from '…/components/popover';

<Popover @placement="bottom-start">
  <:trigger as |trigger|>
    <button type="button" {{trigger}}>
      More
    </button>
  </:trigger>

  <:content>
    <p>Additional actions</p>
    <a href="/docs">Learn more</a>
    <button type="button">Delete</button>
  </:content>
</Popover>
```

Styling is wrap-your-own markup inside `:content`, or `@contentClass` on the portaled wrapper. Same for both widgets.

### Why the modifier is only for tooltips

A modifier cannot take a template block. That is fine for a string description. A popover’s reason to exist is interactive markup, so it is component-only.

Internally `{{tooltip "…"}}` is a small wrapper that creates the same manager the `<Tooltip>` component uses.

## DOM transparency (no wrapper around the trigger)

`<Tooltip>` / `<Popover>` wrap the trigger **in template syntax only**. They do not insert a wrapper element around your button.

Given:

```gts
<div class="toolbar flex gap-2">
  <Tooltip>
    <:trigger as |trigger|>
      <button type="button" {{trigger}}>Save</button>
    </:trigger>
    <:content>...</:content>
  </Tooltip>
</div>
```

The rendered DOM is effectively:

```html
<div class="toolbar flex gap-2">
  <button type="button" aria-describedby="tooltip-1">Save</button>
</div>
<!-- elsewhere, portaled to body when open: -->
<div role="tooltip" id="tooltip-1">...</div>
```

The modifier form is even simpler: there is no component invocation, only attributes/listeners on the button plus a portaled node.

**Hard rule:** never wrap `:trigger` in a `<span>`, `<div>`, or `display: contents` hack.

Add an integration test asserting the trigger element's `parentElement` is unchanged (aside from the portaled floating node).

### Internal template shape (tooltip)

```gts
<template>
  {{yield this.triggerModifier to="trigger"}}

  {{#if this.isOpen}}
    {{#in-element this.portalTarget insertBefore=null}}
      <div
        role="tooltip"
        id={{this.tooltipId}}
        data-state="open"
        class={{@contentClass}}
        {{this.positionModifier}}
      >
        {{yield to="content"}}
      </div>
    {{/in-element}}
  {{/if}}
</template>
```

Popover is the same shape with a different role, interactive pointer events, and focus management on the floating node.

## Architecture

```text
public API
  Tooltip.gts
  Popover.gts
  {{tooltip}} modifier          # string tooltips only

private
  floating-manager.ts           # open state, elements, controlled mode
  position.ts                   # @floating-ui/dom + autoUpdate
  portal.ts
  tooltip/interactions.ts       # hover, focus, delay, Escape, aria-describedby
  popover/interactions.ts       # click, outside click, Escape, focus trap, aria-expanded

@floating-ui/dom
  computePosition
  autoUpdate
  middleware: offset, flip, shift, hide, arrow
```

| Layer | Responsibility |
|---|---|
| `floating-manager` | Open state, ids, reference/floating elements, controlled `@open` |
| Position helper | `computePosition` + `autoUpdate` cleanup |
| Portal | `in-element` target (`document.body` or `@container`) |
| Tooltip interactions | Hover, focus, delays, Escape, `aria-describedby`, `pointer-events: none` |
| Popover interactions | Click toggle, outside click, Escape, focus trap, restore focus, `aria-expanded` |
| `{{tooltip}}` modifier | String content + same tooltip manager |
| Public components | Named blocks, wire manager to the right interaction module |

Manager owns state. Public modifiers/components only register elements and forward events. Do not put “open” logic in two places.

Tooltip extras that ship with the rest (not a second release):

- **Single-open** — opening one tooltip closes the others
- **`TooltipGroup`** — delay groups for toolbars: first tooltip waits, then siblings open instantly while the pointer is still in the group
- **`@arrow`** — Floating UI `arrow` middleware + optional arrow element
- **`@renderInPlace`** — skip the portal when the consumer needs the tooltip in the local DOM

Popover extras that ship with the rest:

- **`@modal`** — focus trap + scrim; click on scrim closes (same as outside click)

Not in this addon: menus, listboxes, hover-to-open popovers, `@interactive` on `<Tooltip>`.

## Phase 1 — Scaffold the v2 addon

The current `@ember/addon-blueprint` is a **single package** (not the older `addon/` + `test-app/` workspace):

```text
src/                 # published addon
tests/               # QUnit (same package)
demo-app/            # Vite playground — not published
.github/workflows/
```

```bash
pnpm dlx ember-cli@latest addon . -b @ember/addon-blueprint --typescript --pnpm
```

This gives:

- Ember **6.7+**, Vite test app, Rollup build for addon code
- GTS (`.gts` / `.gjs`) compiled by the Ember/Vite pipeline — Glint is not involved at runtime
- v2 `ember-addon` metadata + `exports` map
- The blueprint may drop Glint v2 into the repo (`@glint/ember-tsc`). Keep it as a **devDependency** if the VS Code / Cursor extension is useful locally. Keep the blueprint’s `declarations/` / `tsconfig.publish.json` emit — that is how consumers get types.

Post-scaffold cleanup:

- Name the package `floating-ember`
- Add `@floating-ui/dom` as a **dependency**
- Add `ember-modifier` as a **dependency**
- Peer deps: `ember-source >= 6`, `@ember/test-waiters`
- Popover focus trap: prefer a small well-known library (e.g. `focus-trap` or `ember-focus-trap`) over a home-grown one
- Keep declaration publish (`declarations/`, `package.json` `"types"` / `exports.types`). Skip `template-registry.ts` unless the blueprint already added it and removing it is more work than leaving it.
- Initialize git + basic README

## Glint (optional, local only)

The addon **runs without Glint**. Glint never ships to the browser. Consumers who do not use Glint just import the component or modifier and go.

You mentioned Glint so `.gts` lights up in the [Glint v2 VS Code / Cursor extension](https://marketplace.visualstudio.com/items?itemName=typed-ember.glint2-vscode). That only needs:

- `@glint/ember-tsc` (and whatever the blueprint already added) as a **devDependency in this repo**
- `compilerOptions.types` including `@glint/ember-tsc/types` in the local `tsconfig.json`
- The extension installed in the editor

That is the whole Glint contract. Separately, **do publish `.d.ts`** so TS/GTS apps can type `import tooltip from 'floating-ember/modifiers/tooltip'`.

Still **out of scope**:

- Making Glint a peer/runtime dependency
- Spending time on perfect `ModifierLike` block-param types for downstream apps
- Documenting a consumer Glint setup as required
- CI failing the build on `ember-tsc` (local `ember-tsc` is fine)

If Glint’s signatures or yielded-modifier typing get in the way, drop it. TypeScript can still check the `.ts` manager/interaction files. `.gts` still compiles.

Component `interface` signatures are still useful as documentation even without Glint — keep them if they stay cheap, skip the ones that exist only to satisfy the typechecker.

### Source conventions

Public API is authored in `.gts`.

**Tooltip component** — `src/components/tooltip.gts`:

```ts
interface TooltipSignature {
  Element: null;
  Args: {
    placement?: Placement;
    delay?: number;
    closeDelay?: number;
    open?: boolean;
    onOpenChange?: (open: boolean) => void;
    container?: Element | string;
    disabled?: boolean;
    contentClass?: string;
    middleware?: Middleware[];
  };
  Blocks: {
    trigger: [trigger: ModifierLike<TooltipTriggerSignature>];
    content: [];
  };
}
```

**Popover component** — same shape minus delay args, plus `@modal`.

**String tooltip modifier** — public:

```ts
interface TooltipModifierSignature {
  Args: {
    Positional: [text: string];
    Named: {
      placement?: Placement;
      delay?: number;
      closeDelay?: number;
    };
  };
  Element: Element;
}
```

Internal trigger/position modifiers stay unexported.

Integration tests are `.gts` because that is how the Vite test app authors templates, not to feed Glint.

## Phase 2 — Shared floating manager

Create `src/-private/floating-manager.ts`:

- Tracked state: `isOpen`, `referenceEl`, `floatingEl`, `placement`, `middleware`
- Methods: `open()`, `close()`, `toggle()`; tooltip layer adds `scheduleOpen()` / `scheduleClose()`
- Controlled mode: `@open` + `@onOpenChange`
- Element registration used by both widgets

Do not put hover vs click policy in this file.

## Phase 3 — Position + portal

Private position helper based on Floating UI + ember-velcro patterns:

```ts
import { autoUpdate, computePosition, offset, flip, shift, hide } from '@floating-ui/dom';

const cleanup = autoUpdate(reference, floating, async () => {
  const { x, y, middlewareData } = await computePosition(reference, floating, {
    placement,
    middleware: [offset(8), flip(), shift({ padding: 8 }), hide(), ...custom],
  });
  Object.assign(floating.style, { position: 'absolute', left: `${x}px`, top: `${y}px` });
  floating.dataset.side = /* from middlewareData */;
});
```

Default middleware: `offset`, `flip`, `shift`, `hide`. `@arrow` adds Floating UI `arrow`.

Portal: `in-element` to `document.body` or `@container`. Guard `document` for FastBoot; floating UI is client-only.

## Phase 4 — Tooltip

- `<Tooltip>` named blocks
- Public `{{tooltip "…"}}` modifier
- Hover + focus open; blur / mouseleave / Escape close
- `role="tooltip"`, `aria-describedby`
- `pointer-events: none`
- Dev assert on interactive descendants
- Dev assert if the compound trigger modifier never registers an element
- Disabled-button docs: use `aria-disabled`, not `disabled`, if the tooltip must still open
- Single-open across tooltips
- `TooltipGroup` for shared delay
- `@arrow` and `@renderInPlace`

## Phase 5 — Popover

- `<Popover>` named blocks (no string modifier)
- Click trigger to toggle
- Click outside + Escape close
- `role="dialog"`, `aria-expanded` / `aria-controls` / `aria-haspopup`
- Focus moves into the panel; trap while open; restore to trigger on close
- `pointer-events` normal
- Same portal + position stack as tooltip
- `@modal` — scrim + focus lock; Escape and scrim click still close

## Phase 6 — Headless styling

No required CSS shipped.

1. Data attributes: `data-state`, `data-side`, `data-placement`
2. Test app examples: plain CSS, Tailwind, DaisyUI
3. Optional structural sheet (`floating-ember/styles/floating.css`): `position: absolute`, z-index, tooltip `pointer-events: none`. No visual theme.

Do **not** bundle Tailwind / DaisyUI.

## Phase 7 — Tests

Vite + QUnit test app, run by **Testem in real browsers** — not happy-dom / jsdom. Hover, focus, portals, and Floating UI geometry are browser behaviour.

Default delay to `0` in tests (or via helpers). Assert `data-placement` / presence, not pixel coordinates. Query `document` for portaled nodes, not `this.element`.

Export test helpers, e.g. `openTooltip(el)`, `openPopover(el)`.

### Browsers

`choices-ember` / `glide-data-grid-ember` launch Chrome only. This addon also launches **Firefox** — tooltip/popover bugs show up there (focus/blur, `mouseenter` vs leaving into a portaled node, click-outside).

`testem.cjs`:

```js
launch_in_ci: ['Chrome', 'Firefox'],
launch_in_dev: ['Chrome'],
browser_args: {
  Chrome: { ci: [process.env.CI ? '--no-sandbox' : null, '--headless', '--disable-dev-shm-usage', '--window-size=1440,900'].filter(Boolean) },
  Firefox: { ci: ['-headless'] },
},
```

`pnpm test` in CI (`ci.yml`) already goes through Testem, so both browsers run in the Tests job. No extra workflow. Ubuntu runners ship Chrome and Firefox.

Safari is not on Linux. Check it locally (`ember test --launch=Safari`) when touching focus or `:focus-visible`. Do not add a macOS CI runner unless Safari starts failing in real use.

Do **not** add Playwright / Cypress. Ember-QUnit + Testem is the runner; a second stack would retest the same thing.

| Test | Assert |
|---|---|
| Tooltip hover | Content visible (after delay when non-zero) |
| Tooltip mouseleave | Content removed |
| Tooltip focus | Tab to trigger opens |
| Tooltip Escape | Closes; hover-open does not invent focus |
| Tooltip portal | Under `body`, not stuck in overflow-hidden |
| Tooltip a11y | `role="tooltip"`, `aria-describedby` |
| Tooltip rich markup | `<strong>` / `<br>` render |
| Tooltip non-interactive | `pointer-events` none; dev assert on `<a>` |
| Tooltip modifier | `<button {{tooltip "…"}}>` works |
| Tooltip DOM transparency | Trigger `parentElement` unchanged |
| Tooltip controlled | `@open` + `@onOpenChange` |
| Popover click | Opens / toggles closed |
| Popover outside click | Closes |
| Popover Escape | Closes and restores focus |
| Popover interactive | Link/button inside is reachable |
| Popover a11y | `aria-expanded`, focus trap |
| Shared | Positioning `data-side` after waiters |
| Tooltip group | After first delay, sibling opens immediately |
| Tooltip single-open | Opening B closes A |
| Arrow | Arrow element positioned when `@arrow` is set |
| renderInPlace | Tooltip stays in local DOM, not under `body` |
| Popover modal | Scrim present; focus stays inside |

Run interaction tests in Testem (Chrome + Firefox), not a node DOM.

## Phase 8 — Docs and publish readiness

- README: when to use tooltip vs popover, both APIs, a11y, disabled buttons, Tailwind / DaisyUI
- `pnpm run lint:publish` before first release
- Export map: components, `{{tooltip}}` modifier, test helpers — not private position/trigger modifiers
- Publish `.d.ts` via the blueprint prepack path; do not document a consumer Glint setup as required

## File layout

```text
src/
  index.ts
  components/
    tooltip.gts
    tooltip-group.gts
    popover.gts
  modifiers/
    tooltip.ts
  styles/
    floating.css
  test-support.ts
  -private/
    floating-manager.ts
    position.ts
    portal.ts
    interactions.ts
demo-app/                      # Vite demo, not published
tests/integration/
  tooltip-test.gts
  tooltip-modifier-test.gts
  tooltip-group-test.gts
  popover-test.gts
```

## What ships

No second release in this plan. The addon includes:

- Scaffold as `floating-ember` (Glint local-only, not a ship gate)
- Shared floating manager + position + portal
- Tooltip named-block API + `{{tooltip}}` modifier
- Tooltip a11y, non-interactive policy, single-open, `TooltipGroup`, `@arrow`, `@renderInPlace`
- Popover named-block API, focus trap, outside click, `@modal`
- Tests + helpers for all of the above
- Headless examples in the test app (plain CSS, Tailwind, DaisyUI)
- Optional structural CSS sheet

Not this addon: menus, listboxes, hover-to-open popovers.

## Dependencies

- **`@floating-ui/dom`** — positioning
- **`ember-modifier`** — modifier classes
- **`@glint/ember-tsc`** — optional **devDependency** only, for the editor extension
- **Native `in-element`** — portal
- **Focus library** — popovers only
- **No `@floating-ui/react`** — interactions are Ember code in `-private`

## Risks

| Risk | Mitigation |
|---|---|
| Treating popover as “interactive tooltip” | Separate components; no `@interactive` flag |
| rAF positioning flakes | `@ember/test-waiters` + `await settled()`; no pixel asserts |
| Wrapper elements breaking layout | Trigger modifier on the consumer's element |
| FastBoot SSR | Guard `document`; floating UI client-only |
| Glint becoming publish/CI overhead | Local-only; drop it if signatures fight the code |
| Slow / flaky tooltip tests | Default delay 0 + exported helpers |
| Package name clash | Publish as `floating-ember` |

## Implementation todos

1. Scaffold v2 addon as `floating-ember`; keep declaration emit; Glint local-only
2. Shared `floating-manager` + position + portal (`@arrow`, `@renderInPlace`, `@container`)
3. Tooltip interactions, `<Tooltip>`, `{{tooltip}}` modifier, content-policy assert, single-open
4. `TooltipGroup` delay groups
5. Tooltip tests + helpers (DOM transparency, modifier, group, arrow, renderInPlace)
6. Popover interactions, `<Popover>`, focus trap, `@modal`
7. Popover tests + helpers
8. README + test-app demos (tooltip vs popover, Tailwind / DaisyUI)
