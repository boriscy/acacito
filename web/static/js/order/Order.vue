<template>
  <div class="order">

    <div class="header">
      <div class="left">
        <div class="title">{{formatNum(order.num)}} - {{user_client.full_name}}</div>

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
        <a v-if="next" @click="moveNext()" class="next" v-bind:class="nextStatus(order.status)">
          <i class="material-icons">forward</i>
        </a>
      </div>
    </div>
    <!--It will update the view-->
    <span style="display:none">{{now}}</span>
  </div>

</template>

<script>
import {translate, format} from '../mixins'
import orderMixin from './orderMixin'

export default {
  name: 'Order',
  mixins: [translate, format, orderMixin],
  computed: {
    user_client() { return this.order.user_client }
  }
}
</script>
