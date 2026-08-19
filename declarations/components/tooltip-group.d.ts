import Component from '@glimmer/component';
import type Owner from '@ember/owner';
import { DelayGroup } from '../-private/delay-group.ts';
export interface TooltipGroupSignature {
    Element: null;
    Blocks: {
        default: [];
    };
}
export default class TooltipGroup extends Component<TooltipGroupSignature> {
    group: DelayGroup;
    constructor(owner: Owner, args: object);
    willDestroy(): void;
}
//# sourceMappingURL=tooltip-group.d.ts.map