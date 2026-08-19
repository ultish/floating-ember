import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  settled,
  focus,
  blur,
  triggerKeyEvent,
} from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import Tooltip from '#src/components/tooltip.gts';
import { closeTooltip, openTooltip } from '#src/test-support.ts';

module('Integration | Tooltip', function (hooks) {
  setupRenderingTest(hooks);

  hooks.afterEach(function () {
    document
      .querySelectorAll('[role="tooltip"]')
      .forEach((node) => node.remove());
  });

  test('hover shows content', async function (assert) {
    await render(
      <template>
        <Tooltip>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>Save</button>
          </:trigger>
          <:content>Save your changes</:content>
        </Tooltip>
      </template>,
    );

    assert.dom('[role="tooltip"]', document).doesNotExist();
    await openTooltip(document.querySelector('[data-test-trigger]')!);
    assert.dom('[role="tooltip"]', document).hasText('Save your changes');
  });

  test('mouseleave hides content', async function (assert) {
    await render(
      <template>
        <Tooltip>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>Save</button>
          </:trigger>
          <:content>Save your changes</:content>
        </Tooltip>
      </template>,
    );

    const trigger = document.querySelector('[data-test-trigger]')!;
    await openTooltip(trigger);
    await closeTooltip(trigger);
    assert.dom('[role="tooltip"]', document).doesNotExist();
  });

  test('focus opens and blur closes', async function (assert) {
    await render(
      <template>
        <Tooltip>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>Save</button>
          </:trigger>
          <:content>From focus</:content>
        </Tooltip>
      </template>,
    );

    const trigger = document.querySelector('[data-test-trigger]')!;
    await focus(trigger);
    assert.dom('[role="tooltip"]', document).hasText('From focus');
    await blur(trigger);
    assert.dom('[role="tooltip"]', document).doesNotExist();
  });

  test('Escape dismisses a focused tooltip without moving focus', async function (assert) {
    await render(
      <template>
        <Tooltip>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>Save</button>
          </:trigger>
          <:content>Escapable</:content>
        </Tooltip>
      </template>,
    );

    const trigger = document.querySelector('[data-test-trigger]')!;
    await focus(trigger);
    await triggerKeyEvent(trigger, 'keydown', 'Escape');
    assert.dom('[role="tooltip"]', document).doesNotExist();
    assert.strictEqual(document.activeElement, trigger);
  });

  test('portals to document.body', async function (assert) {
    await render(
      <template>
        <div class="overflow-hidden">
          <Tooltip>
            <:trigger as |trigger|>
              <button type="button" data-test-trigger {{trigger}}>Save</button>
            </:trigger>
            <:content>Portaled</:content>
          </Tooltip>
        </div>
      </template>,
    );

    await openTooltip(document.querySelector('[data-test-trigger]')!);
    const tip = document.querySelector('[role="tooltip"]');
    assert.ok(tip);
    assert.strictEqual(tip?.parentElement, document.body);
  });

  test('wires aria-describedby when open', async function (assert) {
    await render(
      <template>
        <Tooltip>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>Save</button>
          </:trigger>
          <:content>Described</:content>
        </Tooltip>
      </template>,
    );

    const trigger = document.querySelector('[data-test-trigger]')!;
    await openTooltip(trigger);
    const tip = document.querySelector('[role="tooltip"]');
    assert.ok(tip?.id);
    assert.dom(trigger).hasAttribute('aria-describedby', tip!.id);
  });

  test('renders rich markup', async function (assert) {
    await render(
      <template>
        <Tooltip>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>Save</button>
          </:trigger>
          <:content>
            Cannot be
            <strong>undone</strong>
          </:content>
        </Tooltip>
      </template>,
    );

    await openTooltip(document.querySelector('[data-test-trigger]')!);
    assert.dom('[role="tooltip"] strong', document).hasText('undone');
  });

  test('sets pointer-events none on the tooltip', async function (assert) {
    await render(
      <template>
        <Tooltip>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>Save</button>
          </:trigger>
          <:content>No pointer</:content>
        </Tooltip>
      </template>,
    );

    await openTooltip(document.querySelector('[data-test-trigger]')!);
    const tip = document.querySelector('[role="tooltip"]') as HTMLElement;
    assert.strictEqual(tip.style.pointerEvents, 'none');
  });

  test('does not wrap the trigger element', async function (assert) {
    await render(
      <template>
        <div class="toolbar" data-test-toolbar>
          <Tooltip>
            <:trigger as |trigger|>
              <button type="button" data-test-trigger {{trigger}}>Save</button>
            </:trigger>
            <:content>Tip</:content>
          </Tooltip>
        </div>
      </template>,
    );

    const toolbar = document.querySelector('[data-test-toolbar]');
    const triggerEl = document.querySelector('[data-test-trigger]');
    assert.strictEqual(triggerEl?.parentElement, toolbar);
  });

  test('controlled mode respects @open', async function (assert) {
    class State {
      @tracked open = true;
    }
    const state = new State();

    await render(
      <template>
        <Tooltip @open={{state.open}}>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>Save</button>
          </:trigger>
          <:content>Controlled</:content>
        </Tooltip>
      </template>,
    );

    assert.dom('[role="tooltip"]', document).hasText('Controlled');
    state.open = false;
    await settled();
    assert.dom('[role="tooltip"]', document).doesNotExist();
  });

  test('sets data-placement after positioning', async function (assert) {
    await render(
      <template>
        <Tooltip @placement="bottom">
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>Save</button>
          </:trigger>
          <:content>Placed</:content>
        </Tooltip>
      </template>,
    );

    await openTooltip(document.querySelector('[data-test-trigger]')!);
    await settled();
    assert.dom('[role="tooltip"]', document).hasAttribute('data-side');
  });

  test('renderInPlace keeps the tooltip in the local tree', async function (assert) {
    await render(
      <template>
        <div data-test-host>
          <Tooltip @renderInPlace={{true}}>
            <:trigger as |trigger|>
              <button type="button" data-test-trigger {{trigger}}>Save</button>
            </:trigger>
            <:content>Local</:content>
          </Tooltip>
        </div>
      </template>,
    );

    await openTooltip(document.querySelector('[data-test-trigger]')!);
    const host = document.querySelector('[data-test-host]');
    const tip = document.querySelector('[role="tooltip"]');
    assert.ok(host?.contains(tip));
    assert.notStrictEqual(tip?.parentElement, document.body);
  });

  test('renders an arrow when @arrow is set', async function (assert) {
    await render(
      <template>
        <Tooltip @arrow={{true}}>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>Save</button>
          </:trigger>
          <:content>With arrow</:content>
        </Tooltip>
      </template>,
    );

    await openTooltip(document.querySelector('[data-test-trigger]')!);
    assert.dom('[data-floating-arrow]', document).exists();
  });

  test('arrow paints without any stylesheet import', async function (assert) {
    await render(
      <template>
        <Tooltip @arrow={{true}}>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>Save</button>
          </:trigger>
          <:content>With arrow</:content>
        </Tooltip>
      </template>,
    );

    await openTooltip(document.querySelector('[data-test-trigger]')!);
    const arrow = document.querySelector('[data-floating-arrow]');
    assert.dom(arrow).hasAttribute('fill', 'inherit');
    assert.dom(arrow).hasAttribute('stroke', 'inherit');
    assert
      .dom('[data-floating-arrow] path[stroke-width]', document)
      .exists('default arrowStrokeWidth renders a stroke path');
  });
});
