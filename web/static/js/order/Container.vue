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
import {Socket} from 'phoenix'

import OrderList from './List.vue'
import Order from './Order.vue'
import OrderProcess from './Process.vue'
import { mapGetters, mapActions } from 'vuex'
import {translate} from '../mixins'

export default {
  name: 'OrderContainer',
  mixins: [translate],
  data() {
    return {
      orderComp: Order,
      processComp: OrderProcess,
      channel: null
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
  methods: {
    setChannel() {
      this.socket = new Socket("/socket", {})
      this.socket.connect()

      const chName = window.organization.id
      this.channel = this.socket.channel(`organizations:${chName}`)

      this.channel.join()
        .receive("ok", resp => {
          console.log("Channel join msg:", resp)
        })

      // Listen to channel
      this.channel.on('move:next', msg => {
        this.$store.dispatch('moveNext', {
          order: msg.order,
          orders: this.$store.state.orders.all
        })
      })

      this.channel.on('new:order', order => {
        const msg = `${this.gettext("New order")}: ${order.client} (${order.total})`
        new Notification(msg)
        this.sound.play()
        this.$store.dispatch('addOrder', order)
      })

      let user = `user-${Math.floor(Math.random() * 100000)}`
      this.socket = new Socket("/socket", {})
      this.socket.connect()
      //this.socket.onOpen( ev => console.log("OPEN", ev) )
      //this.socket.onError( ev => console.log("ERROR", ev) )
      //this.socket.onClose( e => console.log("CLOSE", e))



      window.eventHub.$on('move:next', (data) => {
        this.channel.push('move:next', {order: data.order})
      })
    }
  },
  created() {
    this.$store.dispatch('getOrders')
    this.setChannel()

    this.sound = new Audio('/sounds/alert1.mp3');
    Notification.requestPermission().then(function(result) {
      console.log(result)
    });
  }
}
</script>
