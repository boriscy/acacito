<script>
import Modal from '../globals/Modal.vue'
import NullOrder from './NullOrder.vue'

export default {
  name: 'OrderDetail',
  computed: {
    curr () {
      return window.currencies[this.order.currency]
    }
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
    open () {
      this.$refs.modal.open()
    },
    getSrc (src) {
      return src
    },
    moveBack () {
      if (confirm(this.$t('Are you sure to move the order status back?')) ) {
        this.$store.dispatch('moveBack', {order: this.order})
      }
    }
  }
}
</script>

<template>
  <Modal ref="modal" class="order-detail-modal">

    <h3 slot="title" class="title">
      <strong>{{ order.num | num }}</strong> {{order.cli.name}}
    </h3>

    <div slot="body" class="order-detail">
      <div class="flex">
        <h4 class="w50">
          <i class="material-icons text-gray">smartphone</i>&nbsp;
          {{order.cli.mobile_number | phone}}
        </h4>

        <h4 class="w50">
          <i class="material-icons text-gray">watch_later</i>&nbsp;
          {{order.inserted_at | datetime}}
        </h4>

      </div>

      <p>
        <span class="text-gray">{{ 'Address' | translate }}:</span>
        {{order.cli.address}}
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
              <small class="text-gray">{{ curr }}</small>
            </div>
            <div class="subtotal">
              {{(det.quantity * det.price) | number}}
              <small class="text-gray">{{ curr }}</small>
            </div>
          </div>
        </div>
      </div>

      <div class="total">
        {{ 'Total' | translate }}
        {{(order.total) | number}}
        <small class="text-gray">{{ curr }}</small>
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

<style lang="scss">
.order-detail-modal {
  h3.title {
    margin: 2px 10px;
  }
}
</style>
