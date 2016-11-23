import types from './mutation-types'
import axios from 'axios'

export const getOrders = ({commit}) => {
  order.getOrders(orders => {
    commit(types.FETCH_ORDERS, {orders})
  })
}

/*
 * Utility methods to make ajax requests
 */
const orders = {
  getOrders(cb) {
    axios.get('/api/v1/orders')
    .then((res) => {
      console.log(res)
      cb(res.data.orders)
    })
  }
}
