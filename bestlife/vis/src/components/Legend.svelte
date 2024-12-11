<script>
  export let colorScale;
  export let hoveredContinent;
  $: console.log({ hoveredContinent });
  const continents = colorScale.domain().slice().reverse();
</script>

<div
  class="legend"
  on:mouseleave={() => {
    hoveredContinent = null;
  }}
>
  {#each continents as continent}
    <!-- svelte-ignore a11y-mouse-events-have-key-events -->
    <p
      on:mouseover={() => {
        hoveredContinent = continent;
      }}
      class:unhovered={hoveredContinent && hoveredContinent !== continent}
    >
      <span style="background-color: {colorScale(continent)}" />
      {continent}
    </p>
  {/each}
</div>

<style>
  .legend {
    display: flex;
    flex-direction: row;
    justify-content: center;
    flex-wrap: wrap;
    column-gap: 10px;
    row-gap: 5px;
    margin-top: 20px;
  }

  span {
    width: 12px;
    height: 12px;
    display: inline-block;
    border-radius: 50%;
  }

  p {
    transition: opacity 300ms ease;
    cursor: pointer;
  }

  .unhovered {
    opacity: 0.3;
  }
</style>
