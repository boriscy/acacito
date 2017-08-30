<script>
export default {
  props: {
    index: {
      type: Number
    },
    img: {
      type: Object
    }
  }
}
</script>

<template>
  <div class="flex">
    <div class="form-group w70">
      <label>{{ 'Image for' | translate }} ({{ img.ctype | translate }})</label>
      <input type="file" :name="`organization[images][${index}][image]`" class="form-control" />
      <input type="hidden" :name="`organization[images][${index}][ctype]`" :value="img.ctype" />
    </div>
    <div>
      <img :src="img.thumb" />
    </div>
  </div>
</template>
