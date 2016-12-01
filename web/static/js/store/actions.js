import types from './mutation-types'
import axios from 'axios'

export const getOrders = ({commit}) => {
  methods.getOrders(orders => {
    commit(types.FETCH_ORDERS, {orders})
  })
}

export const getOrder = ({commit}, ord_id) => {
  methods.getOrder(order => {
    commit(types.FETCH_ORDER, {order})
  }, ord_id)
}

export const moveNext = ({commit}, data) => {
  methods.moveNext(orders => {
    commit(types.FETCH_ORDERS, {orders})
  }, data)
}

/*
 * Utility methods to make ajax requests
 */
const methods = {
  getOrders(cb) {
    axios.get('/api/orders')
    .then((res) => {
      cb(res.data.orders)
    })
  },
  getOrder(cb, id) {
    axios.get(`/api/orders/${id}`)
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
