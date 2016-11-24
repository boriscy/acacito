import types from './mutation-types'
import axios from 'axios'

export const getOrders = ({commit}) => {
  orders.getOrders(orders => {
    commit(types.FETCH_ORDERS, {orders})
  })
}

export const getOrder = ({commit}, ord_id) => {
  orders.getOrder(order => {
    commit(types.FETCH_ORDER, {order})
  }, ord_id)
}

/*
 * Utility methods to make ajax requests
 */
const orders = {
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
  }
}
