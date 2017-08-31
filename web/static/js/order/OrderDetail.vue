<script>
import Modal from '../globals/Modal.vue'
import {format} from '../mixins'
import NullOrder from './NullOrder.vue'

export default {
  name: 'OrderDetail',
  mixins: [format],
  computed: {
    user_client() { return this.order.user_client },
    currency() { return window.currencies[this.order.currency] },
  },
  components: {
    Modal,
    NullOrder
  },
  props: {
    order: {
      type: Object,
      required: true
    }
  },
  methods: {
    open() {
      this.$refs.modal.open()
    },
    getSrc(src) {
      return src
    },
    moveBack() {
      if(confirm(this.$t('Are you sure to move the order status back?')) ) {
        this.$store.dispatch('moveBack', {order: this.order})
      }
    }
  }
}
</script>

<template>
  <Modal ref="modal" class="order-detail-modal">
    <h3 slot="title">{{order.client_name}} <strong>{{order.total | number}}</strong></h3>

    <div slot="body" class="order-detail">
      <h4>
        <i class="material-icons text-gray">person</i>
        <strong>{{order.client_name}}</strong>
        <i class="material-icons text-gray">smartphone</i>
        {{order.cli.mobile_number | phone}}
      </h4>
      <p>
        <span class="text-gray">{{ 'Address' | translate }}:</span>
        {{order.client_address}}
      </p>
      <p>
        <span class="text-gray">{{ 'More details' | translate }}:</span>
        {{order.other_details}}
      </p>

      <div v-for="det in order.details" class="flex details">

        <div class="left">
          <img :src="getSrc(det.image_thumb)" />
        </div>

        <div class="right">
          <a :href="'/products/' + det.product_id" class="title" target="_blank">
            {{det.name}}
            <span class="variation" v-if="det.variation">({{det.variation}})</span>
          </a>

          <div class="price-line flex">
            <div class="det">
              {{det.quantity}} x
              {{det.price | number}}
              <small class="text-gray">{{currency}}</small>
            </div>
            <div class="subtotal">
              {{(det.quantity * det.price) | number}}
              <small class="text-gray">{{currency}}</small>
            </div>
          </div>
        </div>
      </div>

      <div class="total">
        {{ 'Total' | translate }}
        {{(order.total) | number}}
        <small class="text-gray">{{currency}}</small>
      </div>
    </div>

    <div slot="footer">
      <button class="btn btn-danger" @click="moveBack()" style="float:left" v-if="'process' != order.status">
        <i class="material-icons rotate-180">forward</i>
        {{'Move Back' | translate}}
      </button>

      <NullOrder :order="order" />

      <button class="btn" @click="$refs.modal.close()">{{'Close' | translate}}</button>
    </div>
  </Modal>
</template>
