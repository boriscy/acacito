<template>
  <div class="map">
    MAP
  </div>
</template>
<script>
import {translate, format} from '../mixins'

export default {
  mixins:[translate, format],
  mounted: function() {
    console.log('Map')
  }
}
</script>

