<template>
  <div>
    <h2>Orders</h2>
  </div>
</template>
<script>
import { mapGetters, mapActions } from 'vuex'
import {translate, format} from '../mixins'

export default {
  mixins:[translate, format],
  computed: mapGetters({
    orders: 'orders'
  }),
  created() {
    console.log('List created')
  },
  mounted() {
    console.log('Orders')
  }
}
</script>
