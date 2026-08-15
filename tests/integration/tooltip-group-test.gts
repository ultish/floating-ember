import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, triggerEvent, settled } from '@ember/test-helpers';
import Tooltip from '#src/components/tooltip.gts';
import TooltipGroup from '#src/components/tooltip-group.gts';

module('Integration | TooltipGroup', function (hooks) {
  setupRenderingTest(hooks);

  hooks.afterEach(function () {
    document
      .querySelectorAll('[role="tooltip"]')
      .forEach((node) => node.remove());
  });

  test('opening one tooltip closes the other', async function (assert) {
    await render(
      <template>
        <Tooltip>
          <:trigger as |trigger|>
            <button type="button" data-test-a {{trigger}}>A</button>
          </:trigger>
          <:content>Alpha</:content>
        </Tooltip>
        <Tooltip>
          <:trigger as |trigger|>
            <button type="button" data-test-b {{trigger}}>B</button>
          </:trigger>
          <:content>Beta</:content>
        </Tooltip>
      </template>,
    );

    await triggerEvent('[data-test-a]', 'mouseenter');
    assert.dom('[role="tooltip"]', document).hasText('Alpha');

    await triggerEvent('[data-test-b]', 'mouseenter');
    assert.dom('[role="tooltip"]', document).hasText('Beta');
    assert.dom('[role="tooltip"]', document).exists({ count: 1 });
  });

  test('after the first delay, a sibling opens immediately', async function (assert) {
    await render(
      <template>
        <TooltipGroup>
          <Tooltip @delay={{40}}>
            <:trigger as |trigger|>
              <button type="button" data-test-a {{trigger}}>A</button>
            </:trigger>
            <:content>Alpha</:content>
          </Tooltip>
          <Tooltip @delay={{40}}>
            <:trigger as |trigger|>
              <button type="button" data-test-b {{trigger}}>B</button>
            </:trigger>
            <:content>Beta</:content>
          </Tooltip>
        </TooltipGroup>
      </template>,
    );

    await triggerEvent('[data-test-a]', 'mouseenter');
    assert.dom('[role="tooltip"]', document).doesNotExist();
    await new Promise((resolve) => setTimeout(resolve, 50));
    await settled();
    assert.dom('[role="tooltip"]', document).hasText('Alpha');

    await triggerEvent('[data-test-a]', 'mouseleave');
    await triggerEvent('[data-test-b]', 'mouseenter');
    assert.dom('[role="tooltip"]', document).hasText('Beta');
  });
});
