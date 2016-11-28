<template>
  <div class="order">
    <div class="header">
      <div class="left">
        {{formatNum(order.number)}} - {{order.client}}

        <div class="details">
          <div v-for="det in order.details">
            <span class="det-quantity">{{det.quantity}}</span>
            <span>
              {{det.name}} <strong>{{det.variation}}</strong>
            </span>
          </div>
        </div>
      </div>

      <div class="right">
        <div class="currency">{{currency()}} {{ formatNumber(order.total) }}</div>
        <div class="time-ago">{{timeAgo(order.inserted_at)}}</div>
        <a v-if="next" @click="moveNext()">
          <i class="icon-right-circled next transport-next"></i>
        </a>
      </div>
    </div>
  </div>
</template>

<script>
import {translate, format} from '../mixins'
import orderMixin from './orderMixin'

export default {
  name: 'Process',
  mixins: [translate, format, orderMixin]
}
</script>
