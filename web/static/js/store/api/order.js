import {auth} from './xhr'

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
      cb(res)
    })
    .catch(error => {
      cb(error.response, order_id)
    })
  },
  cancelCall(cb, order_id) {
    auth.delete(`/api/transport/${order_id}`)
    .then((res) => {
      return cb(res)
    })
    .catch(error => {
      cb(error.response, order_id)
    })
  }
}
