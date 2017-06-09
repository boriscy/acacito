<script>
import {format} from '../mixins'
import orderMixin from './orderMixin'
import types from '../store/mutation-types'
import {auth} from '../store/api/xhr'
import Modal from '../globals/Modal.vue'
import VueNotifications from 'vue-notifications'

export default {
  name: 'NullOrder',
  mixins: [format, orderMixin],
  components: {
    Modal
  },
  props: {
    order: {
      type: Object,
      required: true
    }
  },
  computed: {
    valid() {
      return this.form.null_reason.trim().length > 7
    }
  },
  data() {
    return {btnDisabled: false, form: {null_reason: ''}}
  },
  methods: {
    nullOrder() {
      auth.put(`/api/orders/${this.order.id}/null`, {order: this.form})
      .then(resp => {
        this.$store.commit(types.ORDER_UPDATED, {order: resp.data.order})
        this.$refs.modal.close()
      })
    }
  }
}
</script>

<template>
  <div class="ib">
    <button class="btn btn-danger btn-sm" @click="$refs.modal.open()" :disabled="btnDisabled">{{ 'Null' | translate }}</button>
    <Modal ref="modal">
    <div class="title" slot="title">{{'Null order' | translate}} <strong>{{formatNum(order.num) }}</strong> - {{order.client_name}}</div>

      <div slot="body">
        <label>{{'Null reason' | translate}}</label>
        <textarea v-model="form.null_reason" class="form-control">
        </textarea>
      </div>

      <div slot="footer">
        <button class="btn btn-danger" :disabled="!valid" @click="nullOrder()">{{'Null order' | translate}}</button>
        <button class="btn" @click="$refs.modal.close()">{{'Cancel' | translate}}</button>
      </div>
    </Modal>
  </div>
</template>
