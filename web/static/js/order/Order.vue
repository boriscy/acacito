<template>
  <div class="order">

    <div class="header">
      <div class="title">{{formatNumber(order.number)}} - {{order.client}}</div>
      <div clsss="total">{{formatCurrency(order.total)}}</div>
    </div>

    <div class="details">
      <div v-for="det in order.details">
        <span class="det-quantity">{{det.quantity}}</span>
        <span>
          {{det.name}} <strong>{{det.variation}}</strong>
        </span>

        <div class="det-price">{{formatCurrency(det.price)}}<div>
      <div>
    </div>
  </div>

  {{timeAgo(order.inserted_at)}}

</template>

<script>
//import moment from 'moment'
//window.moment = moment

export default {
  name: 'Order',
  props: {
    order: {
      type:Object,
      required: true
    }
  },
  methods: {
    formatNumber(num) {
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
    formatCurrency(num) {
      return this.order.currency + ' ' + num
    },
    timeAgo(t) {
      return moment.utc(t).fromNow()
    }
  }
}
</script>
