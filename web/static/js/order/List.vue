<template>
  <div>
    <h2>{{gettext("Orders")}}</h2>

    <div v-for="order in orders" class="orders">
      <Order :order="order"></Order>
    </div>
  </div>
</template>

<script>
import {translate, format} from '../mixins'
import { mapGetters, mapActions } from 'vuex'
import Order from './Order.vue'

export default {
  name: 'OrderList',
  mixins: [translate, format],
  computed: mapGetters({
    orders: 'orders',
    order: 'order'
  }),
  components: {
    Order
  },
  created() {
    //this.$store.dispatch('getOrder', 'abcdef')
    this.$store.dispatch('getOrders')
  }
}
</script>
