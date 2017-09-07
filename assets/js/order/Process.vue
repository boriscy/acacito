<script>
/********************************************************
 * This is the process order component that uses the Order.vue component and sets the slot `transport`
 * for putting all related data from transport
 */
import Order from './Order.vue'
import {format} from '../mixins'
import Timer from '../globals/Timer.vue'
import types from '../store/mutation-types'

let that = null

export default {
  name: 'Process',
  mixins: [format],
  components: {
    Order: Order,
    Timer: Timer
  },
  props: {
    order: {
      type: Object
    }
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
    trans() {
      if(this.order && this.order.trans) {
        return this.order.trans
      } else {
        return {}
      }
    },
    vehicle() { return this.order.trans.vehicle }
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
    return {call_seconds: 0, countStarted: false, cancelTimerCount: 9 }
  },
  methods: {
    callTransport() {
      this.$store.dispatch('callTransport', {id: this.order.id})
      this.$refs.timer.restart()
    },
    setTimer() {
      const count = (new Date().getTime() - Date.parse(this.order_call.inserted_at)) / 1000
      this.$refs.timer.count = Math.floor(count)
      this.$refs.timer.start()
    },
    cancelCall() {
      this.$store.dispatch('cancelCall', this.order.id)
      .then(r => {
        this.$refs.timer.reset()
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
    if (this.order_call.inserted_at) {
      this.setTimer()
    }
  }
}
</script>

<template>
  <Order :order="order" nextProcess="transport-next">
    <div slot="transport" class="transport" v-if="'delivery' === order.trans.ctype">

      <div v-if="!order.transport_status">
        <button class="btn btn-primary" @click="callTransport()">{{'Call Transport' | translate}}</button>
      </div>

      <div v-show="'calling' === order.transport_status" class="well well-sm">
        <div>
          <Timer ref="timer"/>
          <span class="text-muted">{{'Calling transport' | translate}}</span>
        </div>
        <button class="btn btn-danger btn-sm" v-if="timerCount > cancelTimerCount" @click="cancelCall()">{{'Cancel call' | translate}}</button>
      </div>

      <div v-if="'responded' === order.transport_status" class="transport-set">
        <div>
          <i class="material-icons trans-icon" :title="$t('vehicle')">{{getVehicleIcon(vehicle)}}</i>&nbsp;
          <strong>{{order.trans.name}}</strong>
        </div>
        <div>
          {{order.trans.mobile_number | phone}}
          &nbsp;
          &nbsp;
          <small><i class="material-icons">watch_later</i> {{timeAgo(order.trans.responded_at)}}</small>
        </div>

        <div v-if="!trans.picked_at && trans.picked_arrived_at">
          <strong class="text-red">{{'Transport has arrived' | translate}}</strong>
        </div>
      </div>

      <div v-if="'call_empty'===order.transport_status" class="alert alert-warning">
        <strong>{{'No transport available' | translate}}</strong>
      </div>

    </div>

  </Order>
</template>
