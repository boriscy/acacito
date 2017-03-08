export default {
  computed: {
    next() {
      if(this.order.status == 'transporting' && this.order.user_transport_id) {
        return false
      } else {
        return true
      }
    }
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
      now: 0
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
      this.$store.dispatch('moveNext', this.order)
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
