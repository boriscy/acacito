<script>
import {format} from '../mixins'
import orderMixin from './orderMixin'
import OrderDetail from './OrderDetail.vue'
import NullOrder from  './NullOrder.vue'

export default {
  name: 'Order',
  mixins: [format, orderMixin],
  components: {
    OrderDetail,
    NullOrder
  },
  computed: {
    user_client() { return this.order.user_client }
  }
}
</script>

<template>
  <div class="order">

    <div class="header">
      <div class="left">
        <div class="title">{{formatNum(order.num)}} - {{order.client_name}}</div>

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
          <small>{{currency()}}</small> {{ formatNumber(order.total) }}
        </div>

        <button v-if="next" @click="moveNext()" class="next" :class="nextStatus(order.status)" :disabled="order.loading">
          <i class="material-icons">forward</i>
        </button>
      </div>
    </div>

    <div>
      <NullOrder :order="order" />
      <a class="pointer" @click="$refs.detail.open()">{{'Detail' | translate}}</a>
    </div>
    <!--It will update the view-->
    <span style="display:none">{{now}}</span>

    <OrderDetail ref="detail" :order="order" />
  </div>
</template>
