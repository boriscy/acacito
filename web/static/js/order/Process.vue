<template>
  <Order :order="order" nextProcess="transport-next">
    <div slot="transport" class="transport">
      <div v-if="order.transport.start">
        <i class="icon-cab"></i>
        {{timeAgo(order.transport.start)}}
      </div>
      <div v-if="!order.transport.start">
        <a class="call" @click="callTransport()">{{gettext("Call Transport")}}</a>
      </div>
    </div>
  </Order>
</template>

<script>
/********************************************************
 * This is the process order component that uses the Order.vue component and sets the slot `transport`
 * for putting all related data from transport
 */
import Order from './Order.vue'
import {translate, format} from '../mixins'
import orderMixin from './orderMixin'

export default {
  name: 'Process',
  mixins: [translate, format, orderMixin],
  components: {
    Order: Order
  },
  methods: {
    callTransport() {
      this.$store.dispatch('callTransport', {id: this.order.id})
    }
  },
  mounted() {}
}
</script>
