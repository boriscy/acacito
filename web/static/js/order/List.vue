<template>
  <div>
    <h3>
      {{gettext(title)}}
      <span class="badge" v-bind:class="cssClass">{{orders.length}}</span>
    </h3>

    <div v-for="order in orders" class="orders">
      <Order :order="order" v-bind:next="next"></Order>
    </div>
  </div>
</template>

<script>
import {translate, format} from '../mixins'
import Order from './Order.vue'

export default {
  name: 'OrderList',
  mixins: [translate, format],
  components: {
    Order
  },
  props: {
    orders: {
      type: Array,
      default: []
    },
    next: {
      type: Boolean,
      default: true
    },
    title: '',
    cssClass: ''
  },
  created() {
    //this.$store.dispatch('getOrder', 'abcdef')
    //this.$store.dispatch('getOrders')
  }
}
</script>
