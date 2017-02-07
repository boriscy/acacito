<template>
  <div class="order">

    <div class="header">
      <div class="left">
        <div class="title">{{formatNum(order.num)}} - {{user_client.full_name}}</div>

        <div class="time-ago">{{timeAgo(order.inserted_at)}}</div>
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
        <a v-if="next" @click="moveNext()">
          <i class="icon-right-circled next" v-bind:class="nextProcess"></i>
        </a>
      </div>
    </div>
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
