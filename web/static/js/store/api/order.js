import auth from './auth'

export default {
  getOrders(cb) {
    auth.get('/api/org_orders')
    .then((res) => {
      cb(res.data.orders)
    })
  },
  getOrder(cb, id) {
    auth.get(`/api/org_orders/${id}`)
    .then((res) => {
      cb(res.data.order)
    })
  },
  moveNext(cb, order) {
    auth.put(`/api/org_orders/${order.id}/move_next`)
    .then((res) => {
      cb(res.data)
    })
  }
}
