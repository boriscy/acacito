<script>
import OrderDetail from './OrderDetail.vue'
import NullOrder from  './NullOrder.vue'
import OrderTime from  './OrderTime.vue'

export default {
  name: 'Order',
  components: {
    OrderDetail,
    NullOrder,
    OrderTime
  },
  computed: {
    user_client() { return this.order.user_client },
    next() {
      if('transporting' == this.order.status && this.order.user_transport_id) {
        return false
      } else {
        return true
      }
    },
    client() { return this.order.user_name },
    organization() { return this.order.organization }
  },
  props: {
    order: {
      type:Object,
      required: true
    },
    nextProcess: {
      default: 'process-next'
    }
  },
  methods: {
    currency(order) {
      return window.currencies[this.order.currency]
    },
    // returns the next status for an Order
    nextStatus(status) {
      switch(status) {
        case 'new':
          return 'process'
        case 'process':
        case 'transport':
          return 'transporting'
        case 'transporting':
          return 'delivered'
        default:
          return ''
      }
    },
    //
    moveNext() {
      if('new' == this.order.status) {
        this.$refs.timeModal.open()
      } else {
        this.$store.dispatch('moveNext', this.order)
      }
    },
    moveNextConfirm() {
      const t = this.$refs.timeModal.getTime().toJSON()
      this.$store.dispatch('moveNextConfirm', {order: this.order, params: {process_time: t}})
      this.$refs.timeModal.close()
    },
    //
    presentNext(order) {
      console.log(order.status, order.user_transport_id)
    }
  },
  created() {
    setInterval(() => { this.now = new Date()}, 1000 * 60)
  },
  data() {
    return {
      socket: null,
      channel: null,
      now: 0,
      form: {process_time: 5}
    }
  },
}
</script>

<template>
  <div class="order" :class="order.viewStatus">
    <div class="flex">
      <div class="left">

        <div class="flex">

          <div class="w30">
            <div class="title">{{ order.num | num }}</div>
            <span class="status" :class="order.status">{{order.status | translate}}</span>
          </div>

          <div>
            <div class="name">{{order.cli.name}}</div>
            <div class="mobile_number">
              <i class="material-icons">smartphone</i>
              {{order.cli.mobile_number}}
            </div>
          </div>


        </div>

        <div v-if="0 < order.cli.nulled_orders">
          <a class="pointer text-red">{{'Nulled orders' | translate}}</a>
          <span class="label label-danger">{{order.cli.nulled_orders}}</span>
        </div>

        <div>
          <a class="pointer">{{'Orders made' | translate}}</a>
          <span class="label label-success">{{order.cli.orders}}</span>

        </div>

        <div class="order-time-ago">
          <i class="material-icons">watch_later</i>
          {{timeAgo(order.inserted_at)}}
        </div>

        <div class="details">
          <div v-for="det in order.details">
            <span class="det-quantity">{{det.quantity}}</span>
            <span>
              {{det.name}} <strong>{{det.variation}}</strong>
            </span>
          </div>
        </div>

        <slot name="transport"></slot>
      </div>

      <div class="right">
        <div class="currency">
          {{ formatNumber(order.total) }} <small>{{currency()}}</small>
        </div>

        <button v-if="next" @click="moveNext()" class="next" :class="nextStatus(order.status)" :disabled="order.loading">
          <i class="material-icons">forward</i>
        </button>
      </div>

    </div>

    <div v-if="order.process_time" class="process-time line">
      <span class="text-muted">{{'Order ready at' | translate}}:</span>
      <strong>{{order.process_time | time('hh:mm a')}}</strong>
      &nbsp;
      {{timeAgo(order.process_time)}}
    </div>

    <div v-if="'pickup' === order.trans.ctype" class="pickup line">
      <i class="material-icons">shopping_basket</i>&nbsp;
      <small>{{'Client will pick order' | translate}}</small>
    </div>

    <div>
      <NullOrder :order="order" v-if="'new'==order.status"/>
      <a class="pointer" @click="$refs.detail.open()">{{'Detail' | translate}}</a>
    </div>

    <!--It will update the view time ago-->
    <span style="display:none">{{now}}</span>

    <OrderTime ref="timeModal" :order="order"  />

    <OrderDetail ref="detail" :order="order" />


  </div>
</template>
