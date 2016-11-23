import types from './mutation-types'

// initial state
const state = {
  all: [],
  one: {}
}

const mutations = {
  [types.FETCH_ORDERS] (state, {orders}) {
    state.all = orders
  },
  [types.FETCH_ORDER] (state, {order}) {
    state.one = order
  }
}


export default {
  state,
  mutations
}
