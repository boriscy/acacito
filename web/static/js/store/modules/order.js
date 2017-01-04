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
    state.orders.unshift(order)
  },
  [types.UPDATE_ORDER] (state, {order}) {
    const idx = state.orders.findIndex((ord) => { return ord.id == order.id})

    if(idx > -1) {
      Object.assign(state.orders[idx], order)
    }
    console.log('Ord', order)
  }
}


export default {
  state,
  mutations
}
