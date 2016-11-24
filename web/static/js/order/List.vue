<template>
  <div>
    <h2>{{gettext("Orders")}}</h2>
    HHIHIH
  </div>
</template>

<script>
import {translate, format} from '../mixins'
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'OrderList',
  mixins: [translate, format],
  computed: mapGetters({
    orders: 'orders'
  }),
  created() {
    console.log('List created')
  },
  mounted() {
    console.log('mounted list');
  }
}
</script>
