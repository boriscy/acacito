<template>
  <div class="orders-container">
    <NewOrders :orders="newOrders" title="New Orders" css-class="new">
    </NewOrders>

    <ProcessOrders :orders="processOrders" title="Orders in Process" css-class="process">
    </ProcessOrders>

    <TransportOrders :orders="transportOrders" title="Transporting Orders"
      css-class="transport" v-bind:next="false">
    </TransportOrders>
  </div>
</template>
<script>
import OrderList from './List.vue'
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'OrderContainer',
  components: {
    NewOrders: OrderList,
    ProcessOrders: OrderList,
    TransportOrders: OrderList
  },
  computed: mapGetters({
    newOrders: 'newOrders',
    processOrders: 'processOrders',
    transportOrders: 'transportOrders'
  }),
  created() {
    this.$store.dispatch('getOrders')
  }
}
</script>
