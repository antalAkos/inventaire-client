<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon as iconFn, loadInternalLink } from '#lib/utils'

  export let label
  export let icon
  export let href
  export let title
  export let counter
</script>

<a
  {href}
  on:click={loadInternalLink}
  class="icon-button"
  title={i18n(title)}
>
  {@html iconFn(icon)}
  <span class="label">{I18n(label)}</span>
  {#if counter != null && counter !== 0}
    <span class="counter">{counter}</span>
  {/if}
</a>

<style lang="scss">
  @import "#general/scss/utils";

  .icon-button{
    @include display-flex(row, center, center);
    align-self: stretch;
    text-align: center;
    @include bg-hover-lighten($topbar-bg-color);
  }
  .counter{
    @include counter-commons;
    @include sans-serif;
    text-align: center;
    line-height: 1em;
  }
  /* Small screens */
  @media screen and (max-width: $small-screen){
    .label{
      margin-inline-end: 1em;
    }
    .counter{
      margin-inline-start: auto;
    }
  }

  /* Large screens */
  @media screen and (min-width: $small-screen){
    .icon-button{
      width: 3em;
      padding: 0 0.5em;
      position: relative;
      :global(.fa){
        color: white;
        text-align: center;
        font-size: 1.4em;
      }
    }
    .label{
      display: none;
    }
    .counter{
      @include position(absolute, 0.2em, 0.2em);
    }
  }
</style>
