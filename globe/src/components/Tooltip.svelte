<script>
  export let data;
  import { format } from "d3-format";
  import { fade } from "svelte/transition";
  const numberFormat = (d) => format(".2s")(d).replace("G", "B");
</script>

{#if data?.country}
  <div in:fade>
    <h2>{data.country}</h2>
    <h3>Population of {numberFormat(data.population)}</h3>
  </div>
{/if}

<style>
  div {
    position: absolute;
    color: #f7f9f9;
    bottom: 45px;
    margin-left: 10px;
  }

  h2 {
    margin-bottom: 10px;
    font-weight: 900;
    font-size: 1.5rem;
  }

  h3 {
    font-size: 1.2rem;
    font-weight: 5 00;
  }
</style>
