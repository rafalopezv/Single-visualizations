<script>
  import { format } from "d3-format";
  const legendFormat = (d) => format(".2s")(d).replace("G", "B");
  export let colorScale;
  export let data;
  const minColor = colorScale.range()[0];
  const maxColor = colorScale.range()[1];
  const minValue = colorScale.domain()[0];
  const maxValue = colorScale.domain()[1];
  $: percentPopulation = (data?.population / maxValue) * 100;
  $: console.log(percentPopulation);
  import { fade } from "svelte/transition";
</script>

<div class="legend">
  <span class="label">{legendFormat(minValue)}</span>
  <div
    class="bar"
    style:background="linear-gradient( to right,
    {minColor} 0%,
    {maxColor} 100% )"
  >
    {#if percentPopulation}
      <span class="line" style:left={percentPopulation + "%"} in:fade />
    {/if}
  </div>
  <span class="label">{legendFormat(maxValue)}</span>
</div>

<style>
  .legend {
    display: flex;
    flex-direction: row;
    gap: 6px;
    margin-top: 25px;
    margin-left: 10px;
    position: relative;
  }

  .bar {
    height: 15px;
    width: 100%;
    border-radius: 3px;
    position: relative;
  }

  .label {
    color: #f7f9f9;
    user-select: none;
  }

  .line {
    top: 0;
    height: 15px;
    width: 4px;
    background: #f7f9f9;
    position: absolute;
    border-radius: 5px;
    transition: left 500ms cubic-bezier(1, 0, 0, 1);
  }
</style>
