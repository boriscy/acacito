<template>
  <div class="orders-container">
    <NewOrders :orders="newOrders" title="New Orders" css-class="new"
    v-bind:orderComp="orderComp">
    </NewOrders>

    <ProcessOrders :orders="processOrders" title="Orders in Process"
    css-class="process" v-bind:orderComp="processComp">
    </ProcessOrders>

    <TransportOrders :orders="transportOrders" title="Transporting Orders"
      css-class="transport" v-bind:next="true" v-bind:orderComp="processComp">
    </TransportOrders>
  </div>
</template>

<script>
import {Socket} from 'phoenix'

import OrderList from './List.vue'
import Order from './Order.vue'
import OrderProcess from './Process.vue'
import { mapGetters, mapActions } from 'vuex'
import {translate, format} from '../mixins'
import types from '../store/mutation-types'

export default {
  name: 'OrderContainer',
  mixins: [translate, format],
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
    createMessage(order) {
      return `${this.gettext('New order')}, ${order.user_client.full_name}: ${this.currency(order.currency)}
      ${this.formatNumber(order.total)}`
    },
    setChannel() {
      this.socket = new Socket("/socket", {params: {token: localStorage.getItem('authToken') }})
      this.socket.connect()
      console.log('connect socket', new Date());

      const chName = window.organization.id
      this.channel = this.socket.channel(`organizations:${chName}`)

      this.channel.join()
        .receive("ok", resp => {
          console.log("Channel join msg:", resp)
        })

      // Listen to channel
      this.channel.on('move:next', msg => {
        console.log('move:next', msg.order);
        this.$store.dispatch('moveNext', {
          order: msg.order,
          orders: this.$store.state.orders.all
        })
      })

      this.channel.on('order:created', order => {
        this.$store.commit(types.ADD_ORDER, {order: order})
        this.sound.play()
        new Notification(this.createMessage(order))
      })

      this.channel.on('order:updated', order => {
        this.sound.play()
        this.$store.commit(types.ORDER_UPDATED, {order: order})
      })

      //let user = `user-${Math.floor(Math.random() * 100000)}`
      //this.socket = new Socket("/socket", {})
      //this.socket.connect()
      //this.socket.onOpen( ev => console.log("OPEN", ev) )
      //this.socket.onError( ev => console.log("ERROR", ev) )
      //this.socket.onClose( e => console.log("CLOSE", e))

    }
  },
  created() {
    this.$store.dispatch('getOrders')
    this.setChannel()

    this.sound = new Audio('/sounds/alert1.mp3')
    Notification.requestPermission().then(function(result) {
      console.log(result)
    });

  }
}
</script>
