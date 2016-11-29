<template>
  <Order :order="order" nextProcess="transport-next">
    <div slot="transport" class="transport-data">
      <div v-if="order.transport.start">
        <i class="icon-cab"></i>
        {{timeAgo(order.transport.start)}}
      </div>
      <div v-if="!order.transport.start">
        <a class="call">{{gettext("Call Transport")}}</a>
      </div>
    </div>
  </Order>
</template>

<script>
import Order from './Order.vue'
import {translate, format} from '../mixins'
import orderMixin from './orderMixin'

export default {
  name: 'Process',
  mixins: [translate, format, orderMixin],
  components: {
    Order: Order
  },
  mounted() {
  }
}
</script>
