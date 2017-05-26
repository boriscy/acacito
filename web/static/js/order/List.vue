<template>
  <div class="orders">
    <h3 class="title">
      {{gettext(title)}}
      <span class="badge order-status" v-bind:class="cssClass">{{orders.length}}</span>
    </h3>

    <div v-for="order in orders">
      <!-- orderComp it's been set on Container.vue -->
      <component :order="order" v-bind:next="next" v-bind:is="orderComp"></component>
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
    orderComp: {
      type: Object
    },
    next: {
      type: Boolean,
      default: true
    },
    title: '',
    cssClass: ''
  }
}
</script>
