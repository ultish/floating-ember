import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { LinkTo } from '@ember/routing';
import type Owner from '@ember/owner';
import type { Placement } from '@floating-ui/dom';
import Tooltip from '#src/components/tooltip.gts';
import TooltipGroup from '#src/components/tooltip-group.gts';
import Popover from '#src/components/popover.gts';
import tooltip from '#src/modifiers/tooltip.ts';
import CookbookSection from './components/cookbook-section.gts';

const PLACEMENTS: Placement[] = [
  'top',
  'top-start',
  'top-end',
  'bottom',
  'bottom-start',
  'bottom-end',
  'left',
  'right',
];

const TOC = [
  { id: 'headless', label: 'Headless default' },
  { id: 'modifier', label: 'Modifier (80%)' },
  { id: 'named', label: 'Named blocks' },
  { id: 'options', label: 'Tooltip options' },
  { id: 'group', label: 'Delay group' },
  { id: 'controlled', label: 'Controlled' },
  { id: 'popover', label: 'Popover' },
  { id: 'popover-options', label: 'Popover options' },
  { id: 'styling', label: 'Styling' },
  { id: 'args', label: 'Args reference' },
] as const;

const DAISY_THEMES = [
  'light',
  'dark',
  'cupcake',
  'forest',
  'nord',
  'business',
  'dracula',
  'lemonade',
] as const;

type DaisyTheme = (typeof DAISY_THEMES)[number];

const THEME_KEY = 'floating-ember-demo-theme';

function readTheme(): DaisyTheme {
  if (typeof localStorage === 'undefined') {
    return 'light';
  }
  const stored = localStorage.getItem(THEME_KEY);
  if (stored && (DAISY_THEMES as readonly string[]).includes(stored)) {
    return stored as DaisyTheme;
  }
  return 'light';
}

function applyTheme(theme: DaisyTheme): void {
  if (typeof document === 'undefined') {
    return;
  }
  document.documentElement.setAttribute('data-theme', theme);
  try {
    localStorage.setItem(THEME_KEY, theme);
  } catch {
    // ignore
  }
}

export default class Cookbook extends Component {
  toc = TOC;
  placements = PLACEMENTS;
  daisyThemes = DAISY_THEMES;

  /**
   * Inverted Daisy surface: page uses base-*, tooltip uses base-content.
   * `neutral` is almost the same in light and dark, so it does not track
   * the theme picker.
   */
  // fill-base-content mirrors bg-base-content so the SVG arrow matches —
  // `fill` doesn't inherit from `background-color` the way it would with
  // the old CSS-only diamond arrow.
  tipClass =
    'rounded-box bg-base-content fill-base-content px-2 py-1 text-xs text-base-100 shadow';
  panelClass =
    'floating-panel card bg-base-100 text-base-content shadow-lg p-4 w-56 overflow-visible space-y-2';

  @tracked daisyTheme: DaisyTheme = readTheme();
  @tracked placement: Placement = 'top';
  @tracked delay = 200;
  @tracked closeDelay = 0;
  @tracked arrow = true;
  @tracked disabled = false;
  @tracked popoverPlacement: Placement = 'bottom-start';
  @tracked popoverArrow = true;
  @tracked modal = false;
  @tracked controlledOpen = false;

  constructor(owner: Owner, args: object) {
    super(owner, args);
    applyTheme(this.daisyTheme);
  }

  onTheme = (event: Event): void => {
    const theme = (event.target as HTMLSelectElement).value as DaisyTheme;
    this.daisyTheme = theme;
    applyTheme(theme);
  };

  onPlacement = (event: Event): void => {
    this.placement = (event.target as HTMLSelectElement).value as Placement;
  };

  onPopoverPlacement = (event: Event): void => {
    this.popoverPlacement = (event.target as HTMLSelectElement)
      .value as Placement;
  };

  onDelay = (event: Event): void => {
    this.delay = Number((event.target as HTMLInputElement).value);
  };

  onCloseDelay = (event: Event): void => {
    this.closeDelay = Number((event.target as HTMLInputElement).value);
  };

  toggleArrow = (): void => {
    this.arrow = !this.arrow;
  };

  toggleDisabled = (): void => {
    this.disabled = !this.disabled;
  };

  togglePopoverArrow = (): void => {
    this.popoverArrow = !this.popoverArrow;
  };

  toggleModal = (): void => {
    this.modal = !this.modal;
  };

  toggleControlled = (): void => {
    this.controlledOpen = !this.controlledOpen;
  };

  onOpenChange = (open: boolean): void => {
    this.controlledOpen = open;
  };

  isTheme = (theme: DaisyTheme): boolean => theme === this.daisyTheme;

  isPlacement = (value: Placement): boolean => value === this.placement;

  isPopoverPlacement = (value: Placement): boolean =>
    value === this.popoverPlacement;

  recipeHeadless = `import tooltip from 'floating-ember/modifiers/tooltip';

<button type="button" {{tooltip "Save your changes"}}>
  Save
</button>

// No class. No CSS import. The addon draws a role="tooltip"
// node and positions it. Visual style is yours.`;

  recipePlain = `/* app.css — you write this. The addon does not ship a theme. */
.tip {
  background: #1c1915;
  fill: #1c1915; /* arrow color — SVG's fill doesn't inherit background-color */
  color: #f4efe4;
  font-size: 0.85rem;
  line-height: 1.4;
  padding: 0.4rem 0.65rem;
  border-radius: 4px;
  max-width: 16rem;
}

/* optional: structural rules only (arrow z-index, portal) */
@import 'floating-ember/styles/floating.css';

<button type="button" {{tooltip "Save your changes" arrow=true contentClass="tip"}}>
  Save
</button>

// fill is an inherited SVG property, so setting it once on .tip reaches
// the arrow automatically. Do not set overflow: hidden on .tip or the
// arrow is clipped.`;

  recipeModifier = `import tooltip from 'floating-ember/modifiers/tooltip';

<button
  type="button"
  {{tooltip "Save your changes" placement="top" delay=200 arrow=true contentClass="rounded-box bg-base-content fill-base-content px-2 py-1 text-xs text-base-100 shadow"}}
>
  Save
</button>`;

  recipeNamed = `import Tooltip from 'floating-ember/components/tooltip';

<Tooltip @placement="top" @arrow={{true}} @contentClass="rounded-box bg-base-content fill-base-content px-2 py-1 text-xs text-base-100 shadow">
  <:trigger as |trigger|>
    <button type="button" {{trigger}}>Commit</button>
  </:trigger>
  <:content>
    Writes the index to the current branch.
    <br />
    <strong>Cannot be undone from here.</strong>
  </:content>
</Tooltip>

// No wrapper around the button.
// :content is non-interactive — links belong in <Popover>.`;

  recipeOptions = `<Tooltip
  @placement={{this.placement}}
  @delay={{this.delay}}
  @closeDelay={{this.closeDelay}}
  @arrow={{this.arrow}}
  @disabled={{this.disabled}}
  @contentClass="rounded-box bg-base-content fill-base-content px-2 py-1 text-xs text-base-100 shadow"
>
  <:trigger as |trigger|>
    <button type="button" {{trigger}}>Hover me</button>
  </:trigger>
  <:content>Bound to the controls above</:content>
</Tooltip>`;

  recipeGroup = `import TooltipGroup from 'floating-ember/components/tooltip-group';

<TooltipGroup>
  <Tooltip @contentClass="rounded-box bg-base-content fill-base-content px-2 py-1 text-xs text-base-100 shadow">
    <:trigger as |trigger|>
      <button type="button" {{trigger}}>Cut</button>
    </:trigger>
    <:content>Cut selection</:content>
  </Tooltip>
  <Tooltip @contentClass="rounded-box bg-base-content fill-base-content px-2 py-1 text-xs text-base-100 shadow">…</Tooltip>
</TooltipGroup>

// First tooltip waits @delay. The next one in the group opens instantly.`;

  recipeControlled = `<Tooltip
  @open={{this.open}}
  @onOpenChange={{this.onOpenChange}}
  @contentClass="rounded-box bg-base-content fill-base-content px-2 py-1 text-xs text-base-100 shadow"
>
  <:trigger as |trigger|>
    <button type="button" {{trigger}}>Target</button>
  </:trigger>
  <:content>Open state lives in the parent</:content>
</Tooltip>`;

  recipePopover = `import Popover from 'floating-ember/components/popover';

<Popover @placement="bottom-start" @contentClass="panel">
  <:trigger as |trigger|>
    <button type="button" {{trigger}}>More</button>
  </:trigger>
  <:content>
    <a href="/docs">Learn more</a>
    <button type="button">Delete</button>
  </:content>
</Popover>

// Click to open. Interactive content is allowed. Focus is trapped.`;

  recipePopoverOptions = `<Popover
  @placement={{this.placement}}
  @arrow={{this.arrow}}
  @modal={{this.modal}}
  @contentClass="panel"
>
  <:trigger as |trigger|>
    <button type="button" {{trigger}}>Open</button>
  </:trigger>
  <:content>…</:content>
</Popover>`;

  recipeTailwind = `// In YOUR app — not a floating-ember dependency
// app.css
@import 'tailwindcss';

<button
  type="button"
  {{tooltip
    "Tailwind utilities on the floating node"
    arrow=true
    contentClass="rounded-md bg-slate-800 fill-slate-800 px-2 py-1 text-xs text-slate-100 shadow"
  }}
>
  Save
</button>

<Tooltip
  @arrow={{true}}
  @contentClass="rounded-md bg-slate-800 fill-slate-800 px-2 py-1 text-xs text-slate-100 shadow"
>
  <:trigger as |trigger|>
    <button type="button" {{trigger}}>Commit</button>
  </:trigger>
  <:content>Same class on the named-block API</:content>
</Tooltip>

// contentClass is a string of utilities on the [role=tooltip] node.`;

  recipeDaisy = `// In YOUR app — not a floating-ember dependency
// app.css
@import 'tailwindcss';
@plugin 'daisyui';

<button
  type="button"
  {{tooltip
    "Daisy tokens follow data-theme"
    arrow=true
    contentClass="rounded-box bg-base-content fill-base-content px-2 py-1 text-xs text-base-100 shadow"
  }}
>
  Save
</button>

<Popover
  @arrow={{true}}
  @contentClass="floating-panel card bg-base-100 text-base-content shadow-lg p-4 w-56 overflow-visible"
>
  <:trigger as |trigger|>
    <button type="button" class="btn btn-sm" {{trigger}}>Menu</button>
  </:trigger>
  <:content>
    <a class="link" href="#">Docs</a>
  </:content>
</Popover>

// Switch data-theme on <html> — base-300 / base-content follow it.`;

  <template>
    <div class="min-h-screen bg-base-200 text-base-content">
      <header
        class="sticky top-0 z-20 border-b border-base-300 bg-base-100/95 backdrop-blur"
      >
        <div
          class="mx-auto flex max-w-3xl flex-wrap items-center justify-between gap-3 px-4 py-3"
        >
          <div>
            <p
              class="text-xs font-medium uppercase tracking-wider opacity-50"
            >Cookbook</p>
            <LinkTo
              @route="index"
              class="text-lg font-semibold tracking-tight link link-hover"
            >floating-ember</LinkTo>
          </div>
          <label class="flex items-center gap-2 text-sm">
            <span class="opacity-60">Theme</span>
            <select
              class="select select-bordered select-sm"
              {{on "change" this.onTheme}}
            >
              {{#each this.daisyThemes as |theme|}}
                <option
                  value={{theme}}
                  selected={{this.isTheme theme}}
                >{{theme}}</option>
              {{/each}}
            </select>
          </label>
        </div>
      </header>

      <main class="mx-auto max-w-3xl space-y-12 px-4 py-10">
        <section class="space-y-4">
          <p class="badge badge-warning">Headless by default</p>
          <h2 class="text-3xl font-semibold tracking-tight">
            The addon draws a box. You paint it.
          </h2>
          <p class="text-base leading-relaxed opacity-80">
            <code class="text-sm">floating-ember</code>
            ships no visual theme. A tooltip is a
            <code class="text-sm">role="tooltip"</code>
            node with position, delay, and ARIA. A popover is a
            <code class="text-sm">role="dialog"</code>
            with click, focus trap, and click-outside.
          </p>
          <p class="text-base leading-relaxed opacity-80">
            Every example below
            <strong>adds styling in this demo</strong>
            — plain CSS,
            <strong>optional Tailwind</strong>, or
            <strong>optional DaisyUI</strong>. None of that is a dependency of
            the addon. Skip it and you get the unstyled node. See
            <a href="#styling" class="link">Styling</a>
            for plain CSS, Tailwind, and DaisyUI.
          </p>
          <nav class="flex flex-wrap gap-2 pt-2">
            {{#each this.toc as |item|}}
              <a
                href="#{{item.id}}"
                class="btn btn-xs btn-ghost border border-base-300"
              >{{item.label}}</a>
            {{/each}}
          </nav>
        </section>

        <CookbookSection
          @id="headless"
          @title="Headless default"
          @blurb="No contentClass. No CSS import. The dashed outline is cookbook-only so you can see the node."
          @code={{this.recipeHeadless}}
        >
          <button
            type="button"
            class="btn btn-sm"
            {{tooltip
              "This is the default. No theme."
              contentClass="cookbook-unstyled"
            }}
          >
            Hover — unstyled
          </button>
          <p class="text-xs opacity-60">
            Without the cookbook outline class this is just positioned text.
          </p>
        </CookbookSection>

        <CookbookSection
          @id="modifier"
          @title="Modifier — the 80% case"
          @blurb="Attach the tooltip modifier to your element. No wrapper. Named args match the component."
          @code={{this.recipeModifier}}
        >
          <button
            type="button"
            class="btn btn-sm"
            {{tooltip
              "Save your changes"
              placement="top"
              delay=200
              arrow=true
              contentClass=this.tipClass
            }}
          >
            Save
          </button>
        </CookbookSection>

        <CookbookSection
          @id="named"
          @title="Named blocks — rich, non-interactive"
          @blurb="Use <:content> for line breaks and bold. Links and buttons belong in Popover."
          @code={{this.recipeNamed}}
        >
          <Tooltip
          @placement="top"
          @arrow={{true}}
          @contentClass={{this.tipClass}}
        >
            <:trigger as |trigger|>
              <button
                type="button"
                class="btn btn-sm"
                {{trigger}}
              >Commit</button>
            </:trigger>
            <:content>
              Writes the index to the current branch.
              <br />
              <strong>Cannot be undone from here.</strong>
            </:content>
          </Tooltip>
        </CookbookSection>

        <CookbookSection
          @id="options"
          @title="Tooltip options"
          @blurb="These controls are live. The recipe shows the same args you would bind."
          @code={{this.recipeOptions}}
        >
          <div class="flex flex-wrap items-end gap-3">
            <label class="form-control">
              <span class="label-text text-xs">placement</span>
              <select
                class="select select-bordered select-sm"
                {{on "change" this.onPlacement}}
              >
                {{#each this.placements as |p|}}
                  <option
                    value={{p}}
                    selected={{this.isPlacement p}}
                  >{{p}}</option>
                {{/each}}
              </select>
            </label>
            <label class="form-control">
              <span class="label-text text-xs">delay (ms)</span>
              <input
                class="input input-bordered input-sm w-24"
                type="number"
                min="0"
                step="50"
                value={{this.delay}}
                {{on "input" this.onDelay}}
              />
            </label>
            <label class="form-control">
              <span class="label-text text-xs">closeDelay (ms)</span>
              <input
                class="input input-bordered input-sm w-24"
                type="number"
                min="0"
                step="50"
                value={{this.closeDelay}}
                {{on "input" this.onCloseDelay}}
              />
            </label>
            <label class="label cursor-pointer gap-2">
              <input
                type="checkbox"
                class="checkbox checkbox-sm"
                checked={{this.arrow}}
                {{on "change" this.toggleArrow}}
              />
              <span class="label-text text-sm">arrow</span>
            </label>
            <label class="label cursor-pointer gap-2">
              <input
                type="checkbox"
                class="checkbox checkbox-sm"
                checked={{this.disabled}}
                {{on "change" this.toggleDisabled}}
              />
              <span class="label-text text-sm">disabled</span>
            </label>
          </div>
          <Tooltip
            @placement={{this.placement}}
            @delay={{this.delay}}
            @closeDelay={{this.closeDelay}}
            @arrow={{this.arrow}}
            @disabled={{this.disabled}}
            @contentClass={{this.tipClass}}
          >
            <:trigger as |trigger|>
              <button type="button" class="btn btn-sm" {{trigger}}>Hover me</button>
            </:trigger>
            <:content>
              {{this.placement}}
              · delay
              {{this.delay}}ms
            </:content>
          </Tooltip>
        </CookbookSection>

        <CookbookSection
          @id="group"
          @title="Delay group"
          @blurb="Sweep across a toolbar. The first tooltip waits; the rest open immediately."
          @code={{this.recipeGroup}}
        >
          <TooltipGroup>
            <div class="flex gap-2">
              <Tooltip @delay={{200}} @contentClass={{this.tipClass}}>
                <:trigger as |trigger|>
                  <button
                    type="button"
                    class="btn btn-sm"
                    {{trigger}}
                  >Cut</button>
                </:trigger>
                <:content>Cut selection</:content>
              </Tooltip>
              <Tooltip @delay={{200}} @contentClass={{this.tipClass}}>
                <:trigger as |trigger|>
                  <button
                    type="button"
                    class="btn btn-sm"
                    {{trigger}}
                  >Copy</button>
                </:trigger>
                <:content>Copy selection</:content>
              </Tooltip>
              <Tooltip @delay={{200}} @contentClass={{this.tipClass}}>
                <:trigger as |trigger|>
                  <button
                    type="button"
                    class="btn btn-sm"
                    {{trigger}}
                  >Paste</button>
                </:trigger>
                <:content>Paste from clipboard</:content>
              </Tooltip>
            </div>
          </TooltipGroup>
        </CookbookSection>

        <CookbookSection
          @id="controlled"
          @title="Controlled open"
          @blurb="Pass open and onOpenChange. The button on the left is not the trigger — it just sets state."
          @code={{this.recipeControlled}}
        >
          <div class="flex flex-wrap items-center gap-3">
            <button
              type="button"
              class="btn btn-sm btn-outline"
              {{on "click" this.toggleControlled}}
            >
              {{if this.controlledOpen "Close" "Open"}}
            </button>
            <Tooltip
              @open={{this.controlledOpen}}
              @onOpenChange={{this.onOpenChange}}
              @contentClass={{this.tipClass}}
            >
              <:trigger as |trigger|>
                <button
                  type="button"
                  class="btn btn-sm"
                  {{trigger}}
                >Target</button>
              </:trigger>
              <:content>Parent owns open =
                {{if this.controlledOpen "true" "false"}}</:content>
            </Tooltip>
          </div>
        </CookbookSection>

        <CookbookSection
          @id="popover"
          @title="Popover — interactive"
          @blurb="Click to toggle. Links and buttons are allowed. Escape and click-outside close."
          @code={{this.recipePopover}}
        >
          <Popover
            @placement="bottom-start"
            @contentClass={{this.panelClass}}
            @arrowStrokeWidth={{1}}
          >
            <:trigger as |trigger|>
              <button type="button" class="btn btn-sm" {{trigger}}>More</button>
            </:trigger>
            <:content>
              <p class="text-sm">Additional actions</p>
              <a
                class="link link-primary text-sm"
                href="https://floating-ui.com"
              >Floating UI docs</a>
              <button type="button" class="btn btn-xs btn-ghost">Delete</button>
            </:content>
          </Popover>
        </CookbookSection>

        <CookbookSection
          @id="popover-options"
          @title="Popover options"
          @blurb="modal adds a scrim. Placement is the same Floating UI set."
          @code={{this.recipePopoverOptions}}
        >
          <div class="flex flex-wrap items-end gap-3">
            <label class="form-control">
              <span class="label-text text-xs">placement</span>
              <select
                class="select select-bordered select-sm"
                {{on "change" this.onPopoverPlacement}}
              >
                {{#each this.placements as |p|}}
                  <option
                    value={{p}}
                    selected={{this.isPopoverPlacement p}}
                  >{{p}}</option>
                {{/each}}
              </select>
            </label>
            <label class="label cursor-pointer gap-2">
              <input
                type="checkbox"
                class="checkbox checkbox-sm"
                checked={{this.popoverArrow}}
                {{on "change" this.togglePopoverArrow}}
              />
              <span class="label-text text-sm">arrow</span>
            </label>
            <label class="label cursor-pointer gap-2">
              <input
                type="checkbox"
                class="checkbox checkbox-sm"
                checked={{this.modal}}
                {{on "change" this.toggleModal}}
              />
              <span class="label-text text-sm">modal</span>
            </label>
          </div>
          <Popover
            @placement={{this.popoverPlacement}}
            @arrow={{this.popoverArrow}}
            @arrowStrokeWidth={{1}}
            @modal={{this.modal}}
            @contentClass={{this.panelClass}}
          >
            <:trigger as |trigger|>
              <button type="button" class="btn btn-sm" {{trigger}}>Open</button>
            </:trigger>
            <:content>
              <p class="text-sm">{{this.popoverPlacement}}{{if
                  this.modal
                  " · modal"
                }}</p>
              <button type="button" class="btn btn-xs mt-2">Inside</button>
            </:content>
          </Popover>
        </CookbookSection>

        <section
          id="styling"
          class="space-y-8 [scroll-margin-top:var(--cookbook-sticky-offset)]"
        >
          <div class="space-y-2">
            <h2 class="text-2xl font-semibold tracking-tight">Styling</h2>
            <p class="text-sm leading-relaxed opacity-70">
              The hook is
              <code>contentClass</code>
              (or your own markup inside
              <code>:content</code>). The addon never requires a CSS framework.
              Pick one of the three recipes below. Popovers use a light
              border; the arrow is an SVG triangle, so
              <code>@arrowStrokeWidth</code>
              (matching the border's px width) and CSS
              <code>fill</code>/<code>stroke</code>
              on
              <code>[data-floating-arrow]</code>
              are all it takes to match.
            </p>
            <ul class="text-sm opacity-70 list-disc ps-5 space-y-1">
              <li>
                <a href="#styling-plain" class="link">Plain CSS</a>
                — a class you own. Colors are fixed.
              </li>
              <li>
                <a href="#styling-tailwind" class="link">Tailwind</a>
                — utilities on
                <code>contentClass</code>. Optional.
              </li>
              <li>
                <a href="#styling-daisy" class="link">DaisyUI</a>
                — semantic tokens. Follows the theme picker. Optional.
              </li>
            </ul>
          </div>

          <CookbookSection
            @id="styling-plain"
            @title="Plain CSS"
            @blurb="Write a class. Pass it as contentClass. Hard-coded colors — this one ignores the theme picker."
            @code={{this.recipePlain}}
          >
            <button
              type="button"
              class="btn btn-sm"
              {{tooltip
                "Save your changes"
                arrow=true
                contentClass="tip-plain"
              }}
            >
              Save
            </button>
          </CookbookSection>

          <CookbookSection
            @id="styling-tailwind"
            @title="Tailwind — optional"
            @blurb="Not a dependency. Put utilities on contentClass. The app owns the Tailwind pipeline."
            @code={{this.recipeTailwind}}
          >
            <div class="flex flex-wrap gap-2">
              <button
                type="button"
                class="btn btn-sm"
                {{tooltip
                  "Tailwind utilities on the floating node"
                  arrow=true
                  contentClass="rounded-md bg-slate-800 fill-slate-800 px-2 py-1 text-xs text-slate-100 shadow"
                }}
              >
                Modifier
              </button>
              <Tooltip
                @arrow={{true}}
                @contentClass="rounded-md bg-slate-800 fill-slate-800 px-2 py-1 text-xs text-slate-100 shadow"
              >
                <:trigger as |trigger|>
                  <button
                    type="button"
                    class="btn btn-sm"
                    {{trigger}}
                  >Component</button>
                </:trigger>
                <:content>Same class on the named-block API</:content>
              </Tooltip>
            </div>
          </CookbookSection>

          <CookbookSection
            @id="styling-daisy"
            @title="DaisyUI — optional"
            @blurb="Not a dependency. Tooltips use bg-base-content (inverted against the page) so they stay readable in every theme. Switch the header theme to see it."
            @code={{this.recipeDaisy}}
          >
            <div class="flex flex-wrap gap-2">
              <button
                type="button"
                class="btn btn-sm"
                {{tooltip
                  "Daisy tokens follow data-theme"
                  arrow=true
                  contentClass=this.tipClass
                }}
              >
                Tooltip
              </button>
              <Popover
                @arrow={{true}}
                @arrowStrokeWidth={{1}}
                @contentClass={{this.panelClass}}
              >
                <:trigger as |trigger|>
                  <button
                    type="button"
                    class="btn btn-sm"
                    {{trigger}}
                  >Popover</button>
                </:trigger>
                <:content>
                  <p class="text-sm">Theme =
                    {{this.daisyTheme}}</p>
                  <a class="link link-primary text-sm" href="#">Docs</a>
                </:content>
              </Popover>
            </div>
          </CookbookSection>
        </section>

        <section
          id="args"
          class="space-y-4 [scroll-margin-top:var(--cookbook-sticky-offset)]"
        >
          <h2 class="text-xl font-semibold tracking-tight">Args reference</h2>
          <p class="text-sm opacity-70">
            Shared by
            <code>&lt;Tooltip&gt;</code>
            and the tooltip modifier unless noted.
          </p>
          <div class="overflow-x-auto">
            <table class="table table-sm">
              <thead>
                <tr>
                  <th>Arg</th>
                  <th>On</th>
                  <th>Default</th>
                  <th>Meaning</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td><code>placement</code></td>
                  <td>both + popover</td>
                  <td>top / bottom-start</td>
                  <td>Floating UI placement</td>
                </tr>
                <tr>
                  <td><code>delay</code></td>
                  <td>tooltip</td>
                  <td>200 (0 in tests)</td>
                  <td>ms before open</td>
                </tr>
                <tr>
                  <td><code>closeDelay</code></td>
                  <td>tooltip</td>
                  <td>0</td>
                  <td>ms before close</td>
                </tr>
                <tr>
                  <td><code>open</code>
                    /
                    <code>onOpenChange</code></td>
                  <td>both</td>
                  <td>uncontrolled</td>
                  <td>Controlled mode</td>
                </tr>
                <tr>
                  <td><code>disabled</code></td>
                  <td>both</td>
                  <td>false</td>
                  <td>Ignore hover / click</td>
                </tr>
                <tr>
                  <td><code>contentClass</code></td>
                  <td>both</td>
                  <td>—</td>
                  <td>Class on the floating node</td>
                </tr>
                <tr>
                  <td><code>arrow</code></td>
                  <td>both</td>
                  <td>false</td>
                  <td>Render an SVG
                    <code>data-floating-arrow</code></td>
                </tr>
                <tr>
                  <td><code>arrowWidth</code> /
                    <code>arrowHeight</code></td>
                  <td>both</td>
                  <td>14 / 7</td>
                  <td>Arrow triangle size, px</td>
                </tr>
                <tr>
                  <td><code>arrowTipRadius</code></td>
                  <td>both</td>
                  <td>0</td>
                  <td>Round the arrow's tip</td>
                </tr>
                <tr>
                  <td><code>arrowStrokeWidth</code></td>
                  <td>both</td>
                  <td>0</td>
                  <td>Match the panel's
                    <code>border-width</code>
                    so the stroke geometry lines up</td>
                </tr>
                <tr>
                  <td><code>renderInPlace</code></td>
                  <td>both</td>
                  <td>false</td>
                  <td>Skip portal to body</td>
                </tr>
                <tr>
                  <td><code>container</code></td>
                  <td>both</td>
                  <td>document.body</td>
                  <td>Portal target</td>
                </tr>
                <tr>
                  <td><code>middleware</code></td>
                  <td>both</td>
                  <td>offset/flip/shift/hide</td>
                  <td>Extra Floating UI middleware</td>
                </tr>
                <tr>
                  <td><code>modal</code></td>
                  <td>popover only</td>
                  <td>false</td>
                  <td>Scrim + focus lock</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </main>
    </div>
  </template>
}
