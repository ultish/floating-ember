import { click, triggerEvent } from '@ember/test-helpers';

async function openTooltip(element) {
  await triggerEvent(element, 'mouseenter');
}
async function closeTooltip(element) {
  await triggerEvent(element, 'mouseleave');
}
async function openPopover(element) {
  await click(element);
}
async function closePopover(element) {
  await click(element);
}

export { closePopover, closeTooltip, openPopover, openTooltip };
//# sourceMappingURL=test-support.js.map
