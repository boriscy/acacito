<template>
  <div class="order">

    <div class="header">
      <div class="left">
        {{formatNum(order.number)}} - {{order.client}}

        <div class="details">
          <div v-for="det in order.details">
            <span class="det-quantity">{{det.quantity}}</span>
            <span>
              {{det.name}} <strong>{{det.variation}}</strong>
            </span>
          </div>
        </div>
      </div>

      <div class="right">
        <div class="currency">{{currency()}} {{ formatNumber(order.total) }}</div>
        <div class="time-ago">{{timeAgo(order.inserted_at)}}</div>
        <a v-if="next" @click="moveNext()">
          <i class="icon-right-circled next" v-bind:class="nextStatus(order.status) + '-next'"></i>
        </a>
      </div>
    </div>

  </div>

</template>

<script>
import {translate, format} from '../mixins'

export default {
  name: 'Order',
  mixins: [translate, format],
  props: {
    order: {
      type:Object,
      required: true
    },
    next: {
      type: Boolean,
      default: true
    },
  },
  methods: {
    formatNum(num) {
      let str = String(num)
      switch(str.length) {
        case 1:
          return '00' + num
        case 2:
          return '0' + num
        default:
          return num
      }
    },
    formatNumber(num) {
      return num
    },
    timeAgo(t) {
      return moment.utc(t).fromNow()
    },
    currency(order) {
      return window.currencies[this.order.currency]
    },
    // returns the next status for an Order
    nextStatus(status) {
      switch(status) {
        case 'new':
          return 'process'
        case 'process':
          return 'transport'
        default:
          return ''
      }
    },
    moveNext() {
      this.$store.dispatch('moveNext', {
        order: this.order,
        orders: this.$store.state.orders.all
      })
    }
  }
}
</script>
