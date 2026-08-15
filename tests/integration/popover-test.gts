import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, triggerKeyEvent } from '@ember/test-helpers';
import Popover from '#src/components/popover.gts';
import { openPopover } from '#src/test-support.ts';

module('Integration | Popover', function (hooks) {
  setupRenderingTest(hooks);

  hooks.afterEach(function () {
    document
      .querySelectorAll('[role="dialog"][data-state], [data-floating-scrim]')
      .forEach((node) => node.remove());
  });

  test('click toggles the popover', async function (assert) {
    await render(
      <template>
        <Popover>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>More</button>
          </:trigger>
          <:content>
            <a href="/docs" data-test-link>Learn more</a>
          </:content>
        </Popover>
      </template>,
    );

    const trigger = document.querySelector('[data-test-trigger]')!;
    assert.dom('[role="dialog"]', document).doesNotExist();
    await openPopover(trigger);
    assert.dom('[role="dialog"]', document).exists();
    assert.dom('[data-test-link]', document).exists();
    await click(trigger);
    assert.dom('[role="dialog"]', document).doesNotExist();
  });

  test('sets aria-expanded on the trigger', async function (assert) {
    await render(
      <template>
        <Popover>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>More</button>
          </:trigger>
          <:content>Panel</:content>
        </Popover>
      </template>,
    );

    const trigger = document.querySelector('[data-test-trigger]')!;
    assert.dom(trigger).hasAttribute('aria-expanded', 'false');
    await openPopover(trigger);
    assert.dom(trigger).hasAttribute('aria-expanded', 'true');
    assert.dom(trigger).hasAttribute('aria-haspopup', 'dialog');
  });

  test('click outside closes', async function (assert) {
    await render(
      <template>
        <div>
          <Popover>
            <:trigger as |trigger|>
              <button type="button" data-test-trigger {{trigger}}>More</button>
            </:trigger>
            <:content>Panel</:content>
          </Popover>
          <button type="button" data-test-outside>Outside</button>
        </div>
      </template>,
    );

    await openPopover(document.querySelector('[data-test-trigger]')!);
    await click('[data-test-outside]');
    assert.dom('[role="dialog"]', document).doesNotExist();
  });

  test('Escape closes and restores focus', async function (assert) {
    await render(
      <template>
        <Popover>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>More</button>
          </:trigger>
          <:content>
            <button type="button" data-test-inside>Inside</button>
          </:content>
        </Popover>
      </template>,
    );

    const trigger = document.querySelector('[data-test-trigger]')!;
    await openPopover(trigger);
    await triggerKeyEvent(document, 'keydown', 'Escape');
    assert.dom('[role="dialog"]', document).doesNotExist();
    assert.strictEqual(document.activeElement, trigger);
  });

  test('interactive content is reachable', async function (assert) {
    await render(
      <template>
        <Popover>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>More</button>
          </:trigger>
          <:content>
            <button type="button" data-test-inside>Do it</button>
          </:content>
        </Popover>
      </template>,
    );

    await openPopover(document.querySelector('[data-test-trigger]')!);
    const inside = document.querySelector('[data-test-inside]') as HTMLElement;
    inside.focus();
    assert.strictEqual(document.activeElement, inside);
  });

  test('modal renders a scrim', async function (assert) {
    await render(
      <template>
        <Popover @modal={{true}}>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>More</button>
          </:trigger>
          <:content>Modal panel</:content>
        </Popover>
      </template>,
    );

    await openPopover(document.querySelector('[data-test-trigger]')!);
    assert.dom('[data-floating-scrim]', document).exists();
  });

  test('renders an arrow when @arrow is set', async function (assert) {
    await render(
      <template>
        <Popover @arrow={{true}}>
          <:trigger as |trigger|>
            <button type="button" data-test-trigger {{trigger}}>More</button>
          </:trigger>
          <:content>Pointed</:content>
        </Popover>
      </template>,
    );

    await openPopover(document.querySelector('[data-test-trigger]')!);
    assert.dom('[data-floating-arrow]', document).exists();
  });
});
