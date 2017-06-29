export default {
  computed: {
    next() {
      if(this.order.status == 'transporting' && this.order.user_transport_id) {
        return false
      } else {
        return true
      }
    },
    client() { return this.order.user_name },
    organization() { return this.order.organization }
  },
  props: {
    order: {
      type:Object,
      required: true
    },
    nextProcess: {
      default: 'process-next'
    }
  },
  data() {
    return {
      socket: null,
      channel: null,
      now: 0,
      form: {process_time: 5}
    }
  },
  methods: {
    formatNum(num) {
      let str = String(num)
      switch(str.length) {
        case 1:
          return '00' + num
        case 2:
          return '0' + num
        default:
          return num
      }
    },
    currency(order) {
      return window.currencies[this.order.currency]
    },
    // returns the next status for an Order
    nextStatus(status) {
      switch(status) {
        case 'new':
          return 'process'
        case 'process':
        case 'transport':
          return 'transporting'
        case 'transporting':
          return 'delivered'
        default:
          return ''
      }
    },
    //
    moveNext() {
      if('new' == this.order.status) {
        this.$refs.timeModal.open()
      } else {
        this.$store.dispatch('moveNext', this.order)
      }
    },
    moveNextConfirm() {
      this.$store.dispatch('moveNextConfirm', {order: this.order, params: this.form})
      this.$refs.timeModal.close()
    },
    //
    presentNext(order) {
      console.log(order.status, order.user_transport_id)
    }
  },
  created() {
    setInterval(() => { this.now = new Date()}, 1000 * 60)
  }
}
