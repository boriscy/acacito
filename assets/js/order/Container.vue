<template>
  <div class="orders-main-cont">
    <div v-if="!org.open" class="text-center">
      <br/>
      <button class="btn btn-success btn-lg" @click="openCloseOrg()" :disabled="saving">{{'Open for sale' | translate}}</button>
    </div>

    <button class="close-org" v-if="org.open" @click="openCloseOrg()" :disabled="saving">
      <i class="material-icons">close</i>
      <span class="text">{{'Close sale' | translate}}</span>
    </button>

    <div class="orders-container" v-if="org.open">
      <NewOrders :orders="newOrders" title="New Orders" css-class="new"
      v-bind:orderComp="Order">
      </NewOrders>

      <ProcessOrders :orders="processOrders" title="Orders in Process"
      css-class="process" v-bind:orderComp="Process">
      </ProcessOrders>

      <TransportOrders :orders="transportOrders" title="Transporting Orders"
        css-class="transporting" v-bind:orderComp="Process">
      </TransportOrders>

    </div>
  </div>
</template>

<script>
import {Socket} from 'phoenix'

import OrderList from './List.vue'
import Order from './Order.vue'
import Process from './Process.vue'
import {format} from '../mixins'
import types from '../store/mutation-types'

export default {
  name: 'OrderContainer',
  mixins: [format],
  data () {
    return {
      Order,
      Process,
      channel: null,
      saving: false
    }
  },
  components: {
    NewOrders: OrderList,
    ProcessOrders: OrderList,
    TransportOrders: OrderList
  },
  computed: {
    state() { return this.$store.state },
    newOrders() {
      return this.state.order.orders.filter(ord => { return ord.status == 'new' })
    },
    processOrders() {
      return this.state.order.orders.filter(ord => { return 'process' === ord.status || 'transport' === ord.status })
    },
    transportOrders() {
      return this.state.order.orders.filter(ord => { return 'transporting' === ord.status || 'ready' === ord.status })
    },
    org() {
      return this.state.organization.org
    }
  },
  methods: {
    openCloseOrg() {
      this.saving = true
      this.$store.dispatch('openCloseOrganization')
      .then((res) => {
        console.log('org up', res)
        this.saving = false
      })
    },
    createMessage(order) {
      return `${this.$t('New order')}, ${order.user_client.full_name}: ${this.currency(order.currency)}
      ${this.formatNumber(order.total)}`
    },
    setChannel() {
      this.socket = new Socket("/socket", {params: {token: localStorage.getItem('authToken') }})
      this.socket.connect()

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
      // Near org
      this.channel.on('order:near_org', order => {
        this.sound.play()
        this.$store.commit(types.ORDER_UPDATED, {order: order})
      })
      // Near client
      this.channel.on('order:near_client', order => {
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
  ////////////////////////
  mounted() {
    this.$store.dispatch('getOrders')
    this.setChannel()


    this.sound = new Audio('/sounds/alert1.mp3')
    Notification.requestPermission().then(function(result) {
      console.log('Permission for notification', result)
    })

    this.$store.commit('UPDATE_ORGANIZATION', {org: window.organization})
  }
}
</script>
