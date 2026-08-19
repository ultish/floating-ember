import Component from '@glimmer/component';
import { D as DelayGroup, p as pushGroup, a as popGroup } from '../delay-group-DA_KfSs1.js';
import { precompileTemplate } from '@ember/template-compilation';
import { setComponentTemplate } from '@ember/component';

class TooltipGroup extends Component {
  group = new DelayGroup();
  constructor(owner, args) {
    super(owner, args);
    pushGroup(this.group);
  }
  willDestroy() {
    popGroup(this.group);
    super.willDestroy();
  }
  static {
    setComponentTemplate(precompileTemplate("{{!-- template-lint-disable no-yield-only --}}\n{{yield}}", {
      strictMode: true
    }), this);
  }
}

export { TooltipGroup as default };
//# sourceMappingURL=tooltip-group.js.map
