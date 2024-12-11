<script>
  import data from "$data/data1.js";
  import { forceSimulation, forceY, forceX, forceCollide } from "d3-force";
  import { scaleLinear, scaleBand, scaleSqrt, scaleOrdinal } from "d3-scale";
  import { extent, rollups, mean } from "d3-array";

  const simulation = forceSimulation(data);

  let hoveredData;
  let hoveredContinent;
  let groupByContinent = false;

  $: {
    simulation
      .force(
        "x",
        forceX()
          .x((d) => scaleX(d.ladder_score))
          .strength(0.8)
      )
      .force(
        "y",
        forceY()
          .y((d) => (groupByContinent ? scaleY(d.continent) : innerHeight / 2))
          .strength(0.15)
      )
      .force(
        "collide",
        forceCollide()
          .radius((d) => radiusScale(d.gdp) + 0.4)
          .strength(1)
        // .iterations(1)
      )
      .alpha(0.15)
      .alphaDecay(0.0005)
      .restart();
  }

  let nodes = [];
  simulation.on("tick", () => {
    nodes = simulation.nodes();
  });

  $: nodes = simulation.nodes();

  let width = 500;
  let height = 700;

  const margin = {
    top: 40,
    right: 10,
    bottom: 30,
    left: 10,
  };

  const continents = rollups(
    data,
    (v) => mean(v, (d) => d.ladder_score),
    (d) => d.continent
  )
    .sort((a, b) => a[1] - b[1]) // Sort according to value
    .map((d) => d[0]);

  $: innerWidth = width - margin.left - margin.right;
  innerHeight = height - margin.top - margin.bottom;

  $: scaleX = scaleLinear().domain([0, 10]).range([0, innerWidth]);

  let scaleY = scaleBand()
    .domain(continents)
    .range([innerHeight, 0])
    .paddingOuter(0.1)
    .paddingInner(0.6)
    .align(0.5);

  // add a color to each circle

  const colorRange = [
    "#8ecae6",
    "#219ebc",
    "#023047",
    "#ffb703",
    "#fb8500",
    "#c1121f",
  ];
  const colorScale = scaleOrdinal().domain(continents).range(colorRange);

  // radius  & make the bubble size reactive
  const radiusScale = scaleSqrt()
    .domain(extent(data, (d) => d.gdp))
    .range([3, 15]);

  import AxisX from "$components/AxisX.svelte";
  import AxisY from "$components/AxisY.svelte";
  import Legend from "$components/Legend.svelte";
  import Tooltip from "$components/Tooltip.svelte";
  import { stop_propagation } from "svelte/internal";
  import { fade } from "svelte/transition";
</script>

<h1 class="main-title">How close are you to your best possible life?</h1>
<h2 class="main-subtitle">
  Circles are countries, the larger the higher their GDP percapita
</h2>
<br />
<p style="text-align: center;">
  Hover over the continent names and/or circles to get more information | Click
  or tab on the screen to re-arrange | Made by rafalopezv
</p>

<Legend colorScale={colorScale} bind:hoveredContinent={hoveredContinent} />

<!-- svelte-ignore a11y-click-events-have-key-events -->
<div
  class="chart-container"
  bind:clientWidth={width}
  on:click={() => {
    groupByContinent = !groupByContinent;
    hoveredData = null;
  }}
>
  <svg width={width} height={height}>
    <g class="innerchart" transform="translate({margin.left}, {margin.top})">
      <AxisX scaleX={scaleX} height={innerHeight} width={innerWidth} />
      <AxisY scaleY={scaleY} groupByContinent={groupByContinent} />
      {#if hoveredData}
        <line
          x1={hoveredData.x}
          x2={hoveredData.x}
          y1={hoveredData.y}
          y2={innerHeight}
          stroke-width={2}
          stroke={colorScale(hoveredData.continent)}
        >
        </line>
      {/if}
      {#each nodes as node}
        <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
        <circle
          in:fade={{ delay: 400 }}
          cx={node.x}
          cy={node.y}
          r={radiusScale(node.gdp)}
          fill={colorScale(node.continent)}
          opacity={hoveredData || hoveredContinent
            ? hoveredData === node || hoveredContinent === node.continent
              ? "1"
              : ".2"
            : "1"}
          stroke="white"
          stroke-width={0.5}
          stroke-opacity={0.4}
          on:mouseover={() => {
            hoveredData = node;
          }}
          on:focus={() => {
            hoveredData = node;
          }}
          tabindex="0"
          on:click={(e) => {
            e.stopPropagation();
          }}
          on:mouseleave={() => {
            hoveredData = null;
          }}
        />
      {/each}
    </g>
  </svg>
  {#if hoveredData}
    <Tooltip
      data={hoveredData}
      margin={margin}
      radiusScale={radiusScale}
      width={width}
    />
  {/if}
</div>

<style>
  @import url("https://fonts.googleapis.com/css2?family=Inter:wght@100..900&family=Roboto+Mono:ital,wght@0,100..700;1,100..700&display=swap");
  :global(body) {
    font-family: "Inter", sans-serif;
    fill: "#373e4d";
  }

  :global(.text.tick) {
    font-family: "Inter", sans-serif;
    fill: "blue";
  }

  .main-title {
    font-weight: 900;
    font-size: 1.7rem;
    color: #373e4d;
    text-align: center;
  }

  .main-subtitle {
    font-weight: 600;
    font-size: 1.3rem;
    margin-top: 10px;
    color: #373e4d;
    text-align: center;
  }

  circle {
    transition: opacity 400ms ease;
    cursor: pointer;
  }
</style>
