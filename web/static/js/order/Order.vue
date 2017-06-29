<script>
import {format} from '../mixins'
import orderMixin from './orderMixin'
import OrderDetail from './OrderDetail.vue'
import NullOrder from  './NullOrder.vue'
import Modal from '../globals/Modal.vue'

export default {
  name: 'Order',
  mixins: [format, orderMixin],
  components: {
    OrderDetail,
    NullOrder,
    Modal
  },
  computed: {
    user_client() { return this.order.user_client }
  }
}
</script>

<template>
  <div class="order" :class="order.viewStatus">
    <div class="flex">
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

        <div v-if="order.process_time">
          {{order.inserted_at | datetime}}
          <span class="text-muted">Tiempo estimado:</span>
          {{order.process_time}} {{'minutes' | translate}}
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
      <NullOrder :order="order" v-if="'new'==order.status"/>
      <a class="pointer" @click="$refs.detail.open()">{{'Detail' | translate}}</a>
    </div>

    <!--It will update the view time ago-->
    <span style="display:none">{{now}}</span>

    <OrderDetail ref="detail" :order="order" />

    <Modal ref="timeModal" headerCSS="blue">
    <div slot="title">
      <strong>{{formatNum(order.num)}}</strong>
      {{'Estimated time for preparation?' | translate}}
    </div>

      <div slot="body">
        <div class="form-group form-inline">
          <label>{{'Estimated time for preparation?' | translate}}</label>
          <select v-model="form.process_time" class="form-control">
            <option v-for="v in 18" :value="v*5">{{v * 5}} {{'minutes' | translate}}</option>
          </select>
        </div>
      </div>
      <div slot="footer">
        <button class="btn btn-default" @click="$refs.timeModal.close()">{{'Cancel' | translate}}</button>
        <button class="btn btn-success" @click="moveNextConfirm()">{{'Confirm time' | translate}}</button>
      </div>
    </Modal>

  </div>
</template>
