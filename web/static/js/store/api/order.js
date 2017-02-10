import auth from './auth'

export default {
  getOrders(cb) {
    auth.get('/api/orders')
    .then((res) => {
      cb(res.data.orders)
    })
  },
  getOrder(cb, id) {
    auth.get(`/api/orders/${id}`)
    .then((res) => {
      cb(res.data.order)
    })
  },
  moveNext(cb, order) {
    auth.put(`/api/orders/${order.id}/move_next`)
    .then((res) => {
      cb(res.data)
    })
  },
  callTransport(cb, order_id) {
    auth.post('/api/transport', {order_id: order_id})
    .then((res) => {
      console.log('res', res);
      cb(res)
    })
    .catch(res => {
      console.log('err', arguments);
    })
  }
}
