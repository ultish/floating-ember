import Component from '@glimmer/component';
import type Owner from '@ember/owner';
import { DelayGroup, popGroup, pushGroup } from '../-private/delay-group.ts';

export interface TooltipGroupSignature {
  Element: null;
  Blocks: {
    default: [];
  };
}

export default class TooltipGroup extends Component<TooltipGroupSignature> {
  group = new DelayGroup();

  constructor(owner: Owner, args: object) {
    super(owner, args);
    pushGroup(this.group);
  }

  willDestroy(): void {
    popGroup(this.group);
    super.willDestroy();
  }

  <template>
    {{! template-lint-disable no-yield-only }}
    {{yield}}
  </template>
}
