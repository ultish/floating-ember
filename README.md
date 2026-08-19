# floating-ember

Headless tooltips and popovers for Ember 6+, positioned with [`@floating-ui/dom`](https://floating-ui.com).


- **Tooltip** — hover + focus, rich but non-interactive text
- **Popover** — click to open, interactive content
- No wrapper element around your trigger
- GTS / TypeScript types published

## Install

```bash
pnpm add floating-ember
```

Peer: `ember-source` >= 6.

## Tooltip — modifier (common case)

```gts
import tooltip from 'floating-ember/modifiers/tooltip';

<button type="button" {{tooltip "Save your changes"}}>
  Save
</button>
```

Named args: `placement`, `delay`, `closeDelay`, `disabled`, `contentClass`.

## Tooltip — named blocks (rich, still non-interactive)

```gts
import Tooltip from 'floating-ember/components/tooltip';

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

`<Tooltip>` is a template boundary only. Your button stays a direct child of its parent. Content portals to `document.body`.

Do not put links or buttons in `:content`. That is a popover.

## Popover

```gts
import Popover from 'floating-ember/components/popover';

<Popover @placement="bottom-start">
  <:trigger as |trigger|>
    <button type="button" {{trigger}}>More</button>
  </:trigger>
  <:content>
    <a href="/docs">Learn more</a>
  </:content>
</Popover>
```

## Also included

| API | Purpose |
|---|---|
| `<TooltipGroup>` | Shared hover delay across a toolbar |
| `@arrow` / `arrow=true` | SVG pointer arrow toward the trigger — see Styling below |
| `@renderInPlace` | Skip the portal |
| `@modal` on `<Popover>` | Scrim + focus lock |
| `@open` / `@onOpenChange` | Controlled mode |
| `@container` | Portal target (`document.body` by default) |
| `@contentClass` | Class on the floating node |

## Styling

The addon is headless. Pass `contentClass` (or wrap markup in `:content`).

- **Plain CSS** — your class, your colors
- **Tailwind** (optional) — utilities on `contentClass`. Not a dependency.
- **DaisyUI** (optional) — `bg-base-content text-base-100` (inverted against the page, so it stays readable across themes). Not a dependency.

Position, z-index, and pointer-events are set inline by the addon regardless
of CSS. The one thing that genuinely needs this stylesheet is `<Popover
@modal={{true}}>`'s dimmed backdrop — skip the import if you don't use that:

```css
@import 'floating-ember/styles/floating.css';
```

The cookbook at the demo app has a **Styling** section with live recipes for all three.

The arrow is an SVG triangle, not a CSS-rotated square — `fill` and `stroke`
are inherited SVG properties, so setting them once on the panel's class (or
directly on `[data-floating-arrow]`) reaches the arrow automatically, with
no stylesheet import needed for that. `@arrowStrokeWidth` defaults to `1`;
pass `0` for a borderless arrow, or match it to the panel's `border` width
so the arrow's stroke geometry sits flush with the border.

## Accessibility

- Tooltip: `role="tooltip"`, `aria-describedby`, Escape closes
- Popover: `role="dialog"`, `aria-expanded` / `aria-haspopup`, focus trap, Escape and click-outside close
- Disabled native buttons do not fire hover/focus. Use `aria-disabled` if the tooltip must still open
- Icon-only triggers need an `aria-label` on the button

## Tests

```ts
import { openTooltip, openPopover } from 'floating-ember/test-support';
```

## Compatibility

Ember 6+. Integration tests run in Chrome and Firefox.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

MIT
