<script>
  export let data;
  export let margin;
  export let radiusScale;
  export let width;
  $: radius = radiusScale(data.gdp);
  let tooltipWidth;
  let tooltipHeight;
  //   moving the tooltip
  $: centeredX = data.x - tooltipWidth - radius + margin.left;
  $: centeredY = data.y - tooltipHeight / 2 - radius / 2;
  //   moving the tooltip in case it des not fit n the left
  $: centeredXRight = data.x + radius + margin.left;
  $: centeredYRigth = data.y - radius - tooltipHeight / 2;
  //   checks if the tooltip is wider than width
  $: x = data.x - tooltipWidth;
  $: console.log({ x, width });
  //   for tooltip transitions
  import { fly, fade } from "svelte/transition";
</script>

<div
  bind:clientWidth={tooltipWidth}
  bind:clientHeight={tooltipHeight}
  class="tooltip"
  style="position:absolute;
    top: {x < 0 ? centeredYRigth : centeredY}px;
    left:{x < 0 ? centeredXRight : centeredX}px;
    "
  in:fade={{ duration: 50, delay: 50 }}
>
  <h1 class="tooltip-title">
    {data.country_name}
  </h1>
  <h2 class="tooltip-score">
    {data.ladder_score} out of 10
  </h2>
  <h2 class="tooltip-score">
    $us {data.gdp} GDP percapita
  </h2>
</div>

<style>
  .tooltip {
    position: absolute;
    background-color: rgba(255, 255, 255, 1);
    backdrop-filter: blur(10px);
    border-radius: 5px;
    border-style: dotted;
    border-width: 1px;
    border-color: rgba(0, 0, 0, 0.1);
    transition: background-color 0.3s;
    color: black;
    font-weight: 400;
    cursor: pointer;
    pointer-events: none;
    font-size: 0.9rem;
    padding: 5px;
    line-height: 1;
    transition:
      top 500ms ease,
      left 500ms ease;
  }

  .tooltip-title {
    font-weight: 900;
    font-size: 1.2rem;
    margin-bottom: 5px;
  }

  .tooltip-score {
    font-size: 1.1rem;
    line-height: 1.2;
  }
</style>
