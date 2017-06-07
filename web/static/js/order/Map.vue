<template>
  <div class="map">
    MAP
  </div>
</template>
<script>
import {format} from '../mixins'

export default {
  mixins:[format],
  mounted: function() {
    console.log('Map')
  }
}
</script>

