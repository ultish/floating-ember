import { pageTitle } from 'ember-page-title';
import { LinkTo } from '@ember/routing';
import { modifier } from 'ember-modifier';
import Tooltip from '#src/components/tooltip.gts';
import TooltipGroup from '#src/components/tooltip-group.gts';
import Popover from '#src/components/popover.gts';
import tooltip from '#src/modifiers/tooltip.ts';

const tip =
  'rounded-box bg-base-content px-2 py-1 text-xs text-base-100 shadow';
const panel =
  'floating-panel card bg-base-100 text-base-content shadow-lg p-4 w-56 overflow-visible space-y-2';

const lightTheme = modifier(() => {
  document.documentElement.setAttribute('data-theme', 'light');
});

<template>
  {{pageTitle "floating-ember"}}

  <div class="min-h-screen bg-base-100 text-base-content" {{lightTheme}}>
    <header class="border-b border-base-300">
      <div
        class="mx-auto flex max-w-xl items-center justify-between gap-4 px-6 py-3"
      >
        <span class="font-semibold tracking-tight">floating-ember</span>
        <LinkTo @route="cookbook" class="btn btn-sm btn-neutral">Cookbook</LinkTo>
      </div>
    </header>

    <main class="mx-auto max-w-xl px-6 py-14">
      <h1 class="text-3xl font-semibold tracking-tight mb-3">
        Tooltips describe. Popovers contain.
      </h1>
      <p class="text-base leading-relaxed opacity-70 mb-10">
        Headless Ember widgets on
        <code class="text-sm">@floating-ui/dom</code>. No wrapper around your
        button.
      </p>

      <section class="space-y-8">
        <div>
          <h2 class="text-sm font-semibold mb-3">80% case — modifier</h2>
          <button
            type="button"
            class="btn btn-sm"
            {{tooltip "Save your changes" arrow=true contentClass=tip}}
          >
            Save
          </button>
        </div>

        <div>
          <h2 class="text-sm font-semibold mb-3">Rich tooltip — named blocks</h2>
          <Tooltip @arrow={{true}} @contentClass={{tip}}>
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
        </div>

        <div>
          <h2 class="text-sm font-semibold mb-3">Toolbar group</h2>
          <TooltipGroup>
            <div class="flex gap-2">
              <Tooltip @arrow={{true}} @contentClass={{tip}}>
                <:trigger as |trigger|>
                  <button
                    type="button"
                    class="btn btn-sm"
                    {{trigger}}
                  >Cut</button>
                </:trigger>
                <:content>Cut selection</:content>
              </Tooltip>
              <Tooltip @arrow={{true}} @contentClass={{tip}}>
                <:trigger as |trigger|>
                  <button
                    type="button"
                    class="btn btn-sm"
                    {{trigger}}
                  >Copy</button>
                </:trigger>
                <:content>Copy selection</:content>
              </Tooltip>
              <Tooltip @arrow={{true}} @contentClass={{tip}}>
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
        </div>

        <div>
          <h2 class="text-sm font-semibold mb-3">Popover — interactive</h2>
          <Popover
            @placement="bottom-start"
            @arrow={{true}}
            @contentClass={{panel}}
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
        </div>
      </section>
    </main>
  </div>
</template>
