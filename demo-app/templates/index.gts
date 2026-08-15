import { pageTitle } from 'ember-page-title';
import { LinkTo } from '@ember/routing';
import { modifier } from 'ember-modifier';
import Tooltip from '#src/components/tooltip.gts';
import TooltipGroup from '#src/components/tooltip-group.gts';
import Popover from '#src/components/popover.gts';
import tooltip from '#src/modifiers/tooltip.ts';

const modifierSnippet = `<button {{tooltip "Save your changes"}}>
  Save
</button>`;

const namedSnippet = `<Tooltip @arrow={{true}}>
  <:trigger as |trigger|>
    <button {{trigger}}>Commit</button>
  </:trigger>
  <:content>
    Writes the index to the current branch.
    <br />
    <strong>Cannot be undone from here.</strong>
  </:content>
</Tooltip>`;

const groupSnippet = `<TooltipGroup>
  <Tooltip @arrow={{true}}>
    <:trigger as |trigger|>
      <button {{trigger}}>Cut</button>
    </:trigger>
    <:content>Cut selection</:content>
  </Tooltip>
  <Tooltip @arrow={{true}}>
    <:trigger as |trigger|>
      <button {{trigger}}>Copy</button>
    </:trigger>
    <:content>Copy selection</:content>
  </Tooltip>
</TooltipGroup>`;

const popoverSnippet = `<Popover @placement="bottom-start" @arrow={{true}}>
  <:trigger as |trigger|>
    <button {{trigger}}>More</button>
  </:trigger>
  <:content>
    <a href="/docs">Learn more</a>
    <button type="button">Delete</button>
  </:content>
</Popover>`;

const lightTheme = modifier(() => {
  const root = document.documentElement;
  root.setAttribute('data-theme', 'light');
  root.setAttribute('data-landing', '');
  return () => {
    root.removeAttribute('data-landing');
  };
});

<template>
  {{pageTitle "floating-ember"}}

  <div class="min-h-screen bg-base-100 text-base-content" {{lightTheme}}>
    <header class="border-b border-base-300">
      <div
        class="mx-auto flex max-w-xl items-center justify-between gap-4 px-6 py-3"
      >
        <span class="font-semibold tracking-tight">floating-ember</span>
        <LinkTo
          @route="cookbook"
          class="btn btn-sm btn-neutral"
        >Cookbook</LinkTo>
      </div>
    </header>

    <main class="mx-auto max-w-xl px-6 py-14">
      <h1 class="text-3xl font-semibold tracking-tight mb-3">
        Tooltips describe. Popovers contain.
      </h1>
      <p class="text-base leading-relaxed opacity-70 mb-10">
        Headless Ember widgets on
        <code class="text-sm">@floating-ui/dom</code>. Simple.
      </p>

      <section class="space-y-8">
        <div>
          <h2 class="text-sm font-semibold mb-3">80% case — modifier</h2>
          <button type="button" {{tooltip "Save your changes"}}>
            Save
          </button>
          <pre
            class="mt-3 overflow-x-auto text-xs leading-relaxed opacity-80"
          ><code>{{modifierSnippet}}</code></pre>
        </div>

        <div>
          <h2 class="text-sm font-semibold mb-3">Rich tooltip — named blocks</h2>
          <Tooltip @arrow={{true}}>
            <:trigger as |trigger|>
              <button type="button" {{trigger}}>Commit</button>
            </:trigger>
            <:content>
              Writes the index to the current branch.
              <br />
              <strong>Cannot be undone from here.</strong>
            </:content>
          </Tooltip>
          <pre
            class="mt-3 overflow-x-auto text-xs leading-relaxed opacity-80"
          ><code>{{namedSnippet}}</code></pre>
        </div>

        <div>
          <h2 class="text-sm font-semibold mb-3">Toolbar group</h2>
          <TooltipGroup>
            <Tooltip @arrow={{true}}>
              <:trigger as |trigger|>
                <button type="button" {{trigger}}>Cut</button>
              </:trigger>
              <:content>Cut selection</:content>
            </Tooltip>
            <Tooltip @arrow={{true}}>
              <:trigger as |trigger|>
                <button type="button" {{trigger}}>Copy</button>
              </:trigger>
              <:content>Copy selection</:content>
            </Tooltip>
          </TooltipGroup>
          <pre
            class="mt-3 overflow-x-auto text-xs leading-relaxed opacity-80"
          ><code>{{groupSnippet}}</code></pre>
        </div>

        <div>
          <h2 class="text-sm font-semibold mb-3">Popover — interactive</h2>
          <Popover
            @placement="bottom-start"
            @arrow={{true}}
            @arrowStrokeWidth={{1}}
          >
            <:trigger as |trigger|>
              <button type="button" {{trigger}}>More</button>
            </:trigger>
            <:content>
              <a href="https://floating-ui.com">Learn more</a>
              <button type="button">Delete</button>
            </:content>
          </Popover>
          <pre
            class="mt-3 overflow-x-auto text-xs leading-relaxed opacity-80"
          ><code>{{popoverSnippet}}</code></pre>
        </div>
      </section>
    </main>
  </div>
</template>
