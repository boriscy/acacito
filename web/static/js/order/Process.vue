<template>
  <Order :order="order" nextProcess="transport-next">
    <div slot="transport" class="transport">
      <div v-if="order.transport.start">
        <i class="icon-cab"></i>
        {{timeAgo(order.transport.start)}}
      </div>

      <div v-if="!order.transport_status">
        <a class="call" @click="callTransport()">{{gettext("Call Transport")}}</a>
      </div>

      <div v-show="order.transport_status=='calling'" class="well well-sm">
        <div>
          <Timer ref="timer"/>
          <span class="text-muted">{{gettext('Calling transport')}}</span>
        </div>
        <button class="btn btn-danger btn-sm" v-if="timerCount > 59" @click="cancelCall()">{{gettext('Cancel call')}}</button>
      </div>

      <div v-if="order.transport_status=='responded'" class="transport text-muted">
        <div>
          <i class="material-icons" :title="gettext(vehicle)">{{getVehicleIcon(vehicle)}}</i>
          {{order.transport.transporter_name}}
        </div>
        <div>{{timeAgo(order.transport.responded_at)}}</div>
      </div>

      <div v-if="order.transport_status=='call_empty'" class="alert alert-warning">
        {{gettext('No transport available')}}
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
import Timer from '../globals/Timer.vue'
import types from '../store/mutation-types'

let that = null

export default {
  name: 'Process',
  mixins: [translate, format, orderMixin],
  components: {
    Order: Order,
    Timer: Timer
  },
  computed: {
    timerCount() {
      if(this.countStarted) {
        return this.$refs.timer.count
      } else {
        return 0
      }
    },
    transportStatus() {
      return this.order.transport_status
    },
    order_call() {
      if(this.order && this.order.order_calls && this.order.order_calls.length > 0) {
        return this.order.order_calls[0]
      } else {
        return {}
      }
    },
    vehicle() { return this.order.transport.vehicle }
  },
  watch: {
    transportStatus: (a, b) => {
      if(a == 'call_empty') {
        setTimeout(() => {
          that.$store.commit(types.RESET_ORDER_CALL, that.order.id)
        }, 5000)
      }
    }
  },
  data() {
    return {call_seconds: 0, countStarted: false }
  },
  methods: {
    callTransport() {
      this.$store.dispatch('callTransport', {id: this.order.id})
      this.$refs.timer.start()
    },
    setTimer() {
      const count = (new Date().getTime() - Date.parse(this.order_call.inserted_at)) / 1000
      this.$refs.timer.count = Math.floor(count)
      this.$refs.timer.start()
    },
    cancelCall() {
      this.$store.dispatch('cancelCall', this.order.id)
      .then(r => {
        this.$refs.timer.count = 0
      })
    },
    getVehicleIcon(vehicle) {
      let v = null
      switch(vehicle) {
        case 'walk':
          v = 'directions_walk'
          break
        case 'car':
          v = 'directions_car'
          break
        case 'bike':
          v = 'directions_bike'
          break
        case 'truck':
          v = 'local_shipping'
          break
        case 'motorcycle':
          v = 'motorcycle_black'
          break
      }

      return v
    }
  },
  mounted() {
    this.countStarted = true
    that = this
    if(this.order_call.inserted_at) {
      this.setTimer()
    }
  }
}
</script>
