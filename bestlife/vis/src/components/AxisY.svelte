<script>
  export let scaleY;
  export let groupByContinent;
  const ticks = scaleY.domain();
  import { fade } from "svelte/transition";
</script>

<g class="y-axis">
  {#each ticks as tick}
    {#if groupByContinent}
      <g class="tick" transition:fade>
        <text class="y-axis-text" y={scaleY(tick)} x={2}>{tick}</text>
      </g>
    {/if}
  {/each}
</g>
