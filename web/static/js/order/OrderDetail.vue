<template>
  <Modal ref="modal">
  <h3 slot="title">{{order.client_name}} <strong>{{order.total | number}}</strong></h3>

    <div slot="body" class="order-detail">
      <h4>
        <strong>{{order.client_name}}</strong>
        {{order.client_number | phone}}
      </h4>

      <div v-for="det in order.details" class="flex details">

        <div class="left">
          <img :src="getSrc(det.image_thumb)" />
        </div>

        <div class="right">
          <a :href="'/products/' + det.product_id" class="title" target="_blank">{{det.name}} <span class="variation">({{det.variation}})</span></a>

          <div class="price-line flex">
            <div class="det">
              {{det.quantity}} x
              <span class="currency">{{order.currency}}</span> {{det.price | number}}
            </div>
            <div class="subtotal">
              <span class="currency">{{order.currency}}</span>
              {{(det.quantity * det.price) | number}}
            </div>
          </div>
        </div>
      </div>

      <div class="total">
        Total
        <span class="currency">{{order.currency}}</span>
        {{(order.total) | number}}
      </div>
    </div>

    <div slot="footer">
      <button class="btn" @click="$refs.modal.close()">{{gettext("Close")}}</button>
    </div>
  </Modal>
</template>

<script>
import Modal from '../globals/Modal.vue'
import {translate, format} from '../mixins'
import orderMixin from './orderMixin'

export default {
  name: 'OrderDetail',
  mixins: [translate, format, orderMixin],
  computed: {
    user_client() { return this.order.user_client }
  },
  components: {
    Modal
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
    }
  },
  mounted() {
  }
}
</script>

