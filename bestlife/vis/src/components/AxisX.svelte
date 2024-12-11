<script>
  export let height;
  export let width;
  export let scaleX;

  $: ticks = scaleX.ticks(4);
  $: length = ticks.length - 1;
</script>

<g class="x-axis">
  {#each ticks as tick, index}
    <g class="tick" transform="translate({scaleX(tick)}, 0)">
      <text
        class="x-axis-text"
        x={0}
        y={height}
        text-anchor={index === length
          ? "end"
          : index === 0
            ? "start"
            : "middle"}>{tick}</text
      >
      <line
        x1="0"
        x2="0"
        y1="0"
        y2={height - 15}
        stroke="black"
        stroke-opacity={1}
        stroke-width={0.15}
        stroke-dasharray="1 1 1"
      ></line>
    </g>
  {/each}
  <text
    class="axis-x-title"
    x={width}
    y={height}
    fill="black"
    text-anchor="end"
    dominant-baseline="hanging"
    dy="15"
  >
    Best possible life &rarr
  </text>

  <text
    class="axis-x-title"
    x={0}
    y={height}
    fill="black"
    text-anchor="start"
    dominant-baseline="hanging"
    dy="15"
  >
    &larr Worst possible life
  </text>
</g>

<style>
  .x-axis-text {
    fill: "#373e4d";
  }
</style>
