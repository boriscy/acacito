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
  moveNext(cb, data) {

    let {order, orders} = data
    let idx = orders.findIndex(o => { return o.id == order.id })
    switch(order.status) {
      case 'new':
        order.status = 'process'
      break;
      case 'process':
        order.status = 'transport'
      break;
    }
    orders.splice(idx, 1)
    orders.unshift(order)

    cb(data.orders)
  }
}
