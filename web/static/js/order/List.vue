<template>
  <div>
    <h2>{{gettext("Orders")}}</h2>
    {{orders}} :: {{order}}
  </div>
</template>

<script>
import {translate, format} from '../mixins'
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'OrderList',
  mixins: [translate, format],
  computed: mapGetters({
    orders: 'orders',
    order: 'order'
  }),
  created() {
    this.$store.dispatch('getOrder', 'abcdef')
    this.$store.dispatch('getOrders')
  },
  mounted() {
    console.log('mounted list', this);
  }
}
</script>
