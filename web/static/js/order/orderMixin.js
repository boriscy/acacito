export default {
  props: {
    order: {
      type:Object,
      required: true
    },
    next: {
      type: Boolean,
      default: true
    },
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
    formatNumber(num) {
      return num
    },
    timeAgo(t) {
      return moment.utc(t).fromNow()
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
          return 'transport'
        default:
          return ''
      }
    },
    moveNext() {
      this.$store.dispatch('moveNext', {
        order: this.order,
        orders: this.$store.state.orders.all
      })
    }
  }
}
