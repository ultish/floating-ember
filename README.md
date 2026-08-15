# floating-ember

Headless tooltips and popovers for Ember 6+, positioned with [`@floating-ui/dom`](https://floating-ui.com).

Tooltips describe. Popovers contain. They share a positioner, not an interaction model.

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
| `@arrow` / `arrow=true` | Attachment arrow toward the trigger. Inherits the floating node's background. |
| `@renderInPlace` | Skip the portal |
| `@modal` on `<Popover>` | Scrim + focus lock |
| `@open` / `@onOpenChange` | Controlled mode |
| `@container` | Portal target (`document.body` by default) |
| `@contentClass` | Class on the floating node |

## Styling

The addon is headless. Pass `contentClass` (or wrap markup in `:content`).

- **Plain CSS** — your class, your colors
- **Tailwind** (optional) — utilities on `contentClass`. Not a dependency.
- **DaisyUI** (optional) — `bg-base-content text-base-100` (inverted against the page). `neutral` barely changes between light and dark. Not a dependency.

Optional structural sheet (arrow, z-index, portal only):

```css
@import 'floating-ember/styles/floating.css';
```

The cookbook at the demo app has a **Styling** section with live recipes for all three.

Popovers typically want a light border and a normal `box-shadow`. Do not put a CSS `border` on the arrow — under `border-box` that shrinks the fill and the caret sits on the panel stroke. Match the fill, then draw the two outer edges with `box-shadow` (see the cookbook). A borderless tooltip should stay fill-only or it picks up `currentcolor` (white lines on a dark chip).

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

## License

MIT
