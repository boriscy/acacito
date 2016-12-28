import types from '../mutation-types'

// initial state
const state = {
  orders: [],
  order: {}
}

const mutations = {
  [types.FETCH_ORDERS] (state, {orders}) {
    state.orders = orders
  },
  [types.FETCH_ORDER] (state, {order}) {
    state.order = order
  },
  [types.ADD_ORDER] (state, {order}) {
    state.orders.push(order)
  }
}


export default {
  state,
  mutations
}
