<script>
export default {
  props: {
    index: {
      type: Number
    }
  }
}
</script>

<template>
  <div>
    <label>{{ 'Image' | translate }}</label>
    <input type="file" :name="`organization[images][${index}][image]`" />
  </div>
</template>
