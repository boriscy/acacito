<script>
import {format} from '../mixins'
import orderMixin from './orderMixin'

export default {
  name: 'NullOrder',
  mixins: [format, orderMixin],
  props: {
    order: {
      type: Object,
      required: true
    }
  },
  methods: {
    nullOrder() {
      confirm(this.$t('Are you sure to null the selected order?'))
    }
  }
}
</script>

<template>
  <button class="btn btn-danger btn-sm" @click="nullOrder()">{{ 'Null' | translate }}</button>
</template>
