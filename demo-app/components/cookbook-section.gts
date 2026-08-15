import Component from '@glimmer/component';

export interface CookbookSectionSignature {
  Element: HTMLElement;
  Args: {
    id: string;
    title: string;
    blurb?: string;
    code: string;
    codeOpen?: boolean;
  };
  Blocks: {
    default: [];
  };
}

export default class CookbookSection extends Component<CookbookSectionSignature> {
  get codeOpen(): boolean {
    return this.args.codeOpen !== false;
  }

  <template>
    <section
      id={{@id}}
      class="space-y-3 border-b border-base-300 pb-10 last:border-b-0 scroll-mt-(--cookbook-sticky-offset)"
      ...attributes
    >
      <header class="space-y-1">
        <h2 class="text-xl font-semibold tracking-tight">{{@title}}</h2>
        {{#if @blurb}}
          <p class="text-sm opacity-70 leading-relaxed">{{@blurb}}</p>
        {{/if}}
      </header>

      <div class="rounded-box border border-base-300 bg-base-100 p-4 space-y-3">
        <p class="text-xs font-medium uppercase tracking-wide opacity-50">
          Live
        </p>
        {{yield}}
      </div>

      <details
        class="rounded-box border border-base-300 bg-base-200/60 group"
        open={{this.codeOpen}}
      >
        <summary
          class="cursor-pointer select-none px-4 py-2.5 text-sm font-medium list-none flex items-center justify-between gap-2"
        >
          <span>How to build this</span>
          <span class="text-xs opacity-50 group-open:hidden">show recipe</span>
          <span class="text-xs opacity-50 hidden group-open:inline">hide</span>
        </summary>
        <pre
          class="overflow-x-auto border-t border-base-300 px-4 py-3 text-xs leading-relaxed font-mono bg-base-300/30 m-0 rounded-b-box"
        ><code>{{@code}}</code></pre>
      </details>
    </section>
  </template>
}
