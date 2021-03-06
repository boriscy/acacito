import {auth} from './xhr'

export default {
  getOrders(cb) {
    auth.get('/api/orders')
    .then((res) => {
      cb(res.data.orders)
    })
  },
  //
  getOrder(id, cb) {
    auth.get(`/api/orders/${id}`)
    .then((res) => {
      cb(res.data.order)
    })
  },
  //
  moveNext(order, cb) {
    auth.put(`/api/orders/${order.id}/move_next`)
    .then((res) => {
      cb(res.data)
    })
  },
  //
  moveNextConfirm({order, params}, cb) {
    auth.put(`/api/orders/${order.id}/move_next`, {order: params})
    .then((res) => {
      cb(res.data)
    })
    .catch((error) => {
      alert('there was an error')
    })
  },
  //
  moveBack({order}, cb) {
    auth.put(`/api/orders/${order.id}/move_back`, {})
    .then((res) => {
      cb(res.data)
    })
    .catch((error) => {
      alert('there was an error')
    })
  },
  //
  callTransport(order_id) {
    return auth.post('/api/transport', {order_id: order_id})
    //  .then((res) => { Promise.resolve(res.data) })
    //  .catch((error) => { Promise.reject(error) })
    //  .then((res) => {
    //    cb(res)
    //  })
    //  .catch(error => {
    //    if (error.response) {
    //      cb(error.response, order_id)
    //    } else if (error.request) {
    //      cb(error.request)
    //    } else {
    //    }
    //  })
  },
  //
  cancelCall(order_id, cb) {
    auth.delete(`/api/transport/${order_id}`)
    .then((res) => {
      return cb(res)
    })
    .catch(error => {
      cb(error.response, order_id)
    })
  }
}
