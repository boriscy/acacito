<template>
  <div class="orders-container">
    <NewOrders :orders="newOrders" title="New Orders" css-class="new" v-bind:orderComp="orderComp">
    </NewOrders>

    <ProcessOrders :orders="processOrders" title="Orders in Process" css-class="process"  v-bind:orderComp="processComp">
    </ProcessOrders>

    <TransportOrders :orders="transportOrders" title="Transporting Orders"
      css-class="transport" v-bind:next="false" v-bind:orderComp="orderComp">
    </TransportOrders>
  </div>
</template>
<script>
import OrderList from './List.vue'
import Order from './Order.vue'
import OrderProcess from './Process.vue'
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'OrderContainer',
  data() {
    return {
      orderComp: Order,
      processComp: OrderProcess
    }
  },
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
