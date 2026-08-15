import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import tooltip from '#src/modifiers/tooltip.ts';
import { openTooltip, closeTooltip } from '#src/test-support.ts';

module('Integration | tooltip modifier', function (hooks) {
  setupRenderingTest(hooks);

  hooks.afterEach(function () {
    document
      .querySelectorAll('[role="tooltip"]')
      .forEach((node) => node.remove());
  });

  test('opens a string tooltip on hover', async function (assert) {
    await render(
      <template>
        <button type="button" data-test-trigger {{tooltip "Save your changes"}}>
          Save
        </button>
      </template>,
    );

    const trigger = document.querySelector('[data-test-trigger]')!;
    await openTooltip(trigger);
    assert.dom('[role="tooltip"]', document).hasText('Save your changes');
    await closeTooltip(trigger);
    assert.dom('[role="tooltip"]', document).doesNotExist();
  });

  test('renders an arrow when arrow=true', async function (assert) {
    await render(
      <template>
        <button type="button" data-test-trigger {{tooltip "Tipped" arrow=true}}>
          Save
        </button>
      </template>,
    );

    await openTooltip(document.querySelector('[data-test-trigger]')!);
    assert.dom('[data-floating-arrow]', document).exists();
  });

  test('does not wrap the host element', async function (assert) {
    await render(
      <template>
        <div data-test-toolbar>
          <button
            type="button"
            data-test-trigger
            {{tooltip "Tip"}}
          >Save</button>
        </div>
      </template>,
    );

    assert.strictEqual(
      document.querySelector('[data-test-trigger]')?.parentElement,
      document.querySelector('[data-test-toolbar]'),
    );
  });
});
