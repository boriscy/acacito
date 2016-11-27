<template>
  <div class="order">

    <div class="header">
      <div class="title">{{formatNum(order.number)}} - {{order.client}}</div>
      <div class="total">
        <div class="currency">{{currency()}} {{ formatNumber(order.total) }}</div>
        <div class="time-ago">{{timeAgo(order.inserted_at)}}</div>
      </div>
    </div>

    <div class="details">
      <div v-for="det in order.details">
        <span class="det-quantity">{{det.quantity}}</span>
        <span>
          {{det.name}} <strong>{{det.variation}}</strong>
        </span>
      <div>
    </div>
  </div>

</template>

<script>
export default {
  name: 'Order',
  props: {
    order: {
      type:Object,
      required: true
    }
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
    }
  }
}
</script>
