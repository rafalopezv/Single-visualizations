<script>
  import data from "$data/data.json";
  import df from "$data/df.json";
  import * as topojson from "topojson-client";
  import Glow from "./components/Glow.svelte";
  import { geoOrthographic, geoPath, geoGraticule, geoCentroid } from "d3-geo";
  import { scaleLinear } from "d3-scale";
  import { extent } from "d3-array";
  import { timer } from "d3-timer";
  import { onMount } from "svelte";
  import { drag } from "d3-drag";
  // for selecting the globe as a native d3 form
  import { select } from "d3-selection";
  import { spring } from "svelte/motion";
  import Tooltip from "./components/Tooltip.svelte";
  import Legend from "./components/Legend.svelte";
  // transition for polygon border on selected country
  import { draw } from "svelte/transition";
  // for style tooltip numbers

  // population range for color scale
  const popRange = extent(df, (d) => d.population);

  $: if (tooltipData) {
    const center = geoCentroid(tooltipData);
    $xRotation = -center[0];
    $yRotation = -center[1];
  }

  let countries = topojson.feature(data, data.objects.countries).features;
  let borders = topojson.mesh(data, data.objects.countries, (a, b) => a !== b);
  $: graticule = geoGraticule()
    .step([5, 5]) // Increase density with 5-degree steps
    .extent([
      [-180, -90],
      [180, 90],
    ]) // Set the extent (optional)
    .precision(0.5);

  $: graticuleData = graticule();

  let width = 700;
  $: height = width;
  // earth natural tilt
  let tilt = 20;
  // rotation
  let xRotation = spring(0, { stiffness: 0.08, damping: 0.4 });
  let yRotation = spring(-30, { stiffness: 0.15, damping: 0.7 });
  let rotationSpeed = 0.5;
  // object for dragging features
  let globe;
  // $: console.log(globe);

  const dragSensitivity = 0.9;
  let dragging = false;

  // onMount to instantiate globe object
  onMount(() => {
    //  extracting to d3 syntax
    const element = select(globe);

    element.call(
      drag()
        .on("drag", (event) => {
          // console.log("page loaded");
          $xRotation = $xRotation + event.dx * dragSensitivity;
          $yRotation = $yRotation - event.dy * dragSensitivity;
          // setting dragging to true if users are dragging
          dragging = true;
        })
        .on("end", () => {
          dragging = false;
        })
    );
  });

  const t = timer(() => {
    if (dragging || tooltipData) return;
    $xRotation += rotationSpeed;
  }, 0);

  $: projection = geoOrthographic()
    .scale(width / 2)
    .rotate([$xRotation, $yRotation, tilt])
    .translate([width / 2, height / 2]);

  $: path = geoPath(projection);

  const colorScale = scaleLinear()
    .domain(popRange)
    .range(["#1FB8FF", "#13407C"]);

  // merge data with map
  countries.forEach((country) => {
    const metadata = df.find((d) => d.id === country.id);
    if (metadata) {
      country.population = metadata.population;
      country.country = metadata.country;
    }
  });

  let tooltipData;
</script>

<div class="chart-container" bind:clientWidth={width}>
  
  <h2>You can rotate the globe to change its position and/or click on any country for more information.</h2>
  <svg
    width={width}
    height={height}
    bind:this={globe}
    class:dragging={dragging}
  >
    <!-- Glow -->
    <Glow />
    <!-- Globe -->
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
    <circle
      r={width / 2}
      cx={width / 2}
      cy={height / 2}
      fill="#1F2733"
      filter="url(#glow)"
      on:click={() => {
        tooltipData = null;
      }}
      on:focus={() => {
        tooltipData = null;
      }}
      tabindex="0"
    />

    <!-- Lat/Lon lines -->
    <path
      d={path(graticuleData)}
      fill="none"
      stroke="#F7F9F9"
      stroke-width={0.1}
    />

    <!-- Countries -->
    {#each countries as country}
      <!-- svelte-ignore a11y-click-events-have-key-events -->
      <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
      <path
        d={path(country)}
        fill={colorScale(country?.population || 0)}
        on:click={() => {
          tooltipData = country;
        }}
        on:focus={() => {
          tooltipData = country;
        }}
        tabindex="0"
      />
    {/each}

    <!-- Borders -->
    <path d={path(borders)} fill="none" stroke="#1F2733" stroke-width={0.3} />

    <!-- Selected country border -->
    {#if tooltipData}
      {#key tooltipData.id}
        <path
          d={path(tooltipData)}
          fill="transparent"
          stroke="#f7f9f9"
          stroke-width={2}
          in:draw
        />
      {/key}
    {/if}
  </svg>
  <Tooltip data={tooltipData} />
  <Legend colorScale={colorScale} data={tooltipData} />
</div>

<style>
  .chart-container {
    max-width: 700px;
    margin: 0 auto;
  }

  :global(body) {
    background: #15202c;
  }

  svg {
    overflow: visible;
  }

  .dragging {
    cursor: grabbing;
  }

  path {
    cursor: pointer;
  }

  path:focus {
    outline: none;
  }

  circle:focus {
    outline: none;
  }

  
  h2 {
    color: #f7f9f9;
    font-size: 1.7rem;
    font-weight: 600;
    text-align: center;
  }

  h2 {
    margin-bottom: 30px;
  }
</style>
