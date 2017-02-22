import types from '../mutation-types'

// initial state
const state = {
  orders: [],
  order: {}
}


const mutations = {
  [types.FETCH_ORDERS] (state, {orders}) {
    orders.forEach((ord) => {
      let obj = {}
      if(ord.transport && ord.transport.transporter_id) {
        obj = {transport_status: 'responded', responded_at: ord.transport.responded_at}
      } else if(ord.order_calls.length > 0) {
        obj = {transport_status: 'calling', responded_at: null}
      } else {
        obj = {transport_status: null, responded_at: null}
      }
      Object.assign(ord, obj)
    })

    state.orders = orders
  },
  [types.FETCH_ORDER] (state, {order}) {
    state.order = order
  },
  [types.ADD_ORDER] (state, {order}) {
    state.orders.unshift(order)
  },
  [types.ORDER_UPDATED] (state, {order}) {
    const idx = state.orders.findIndex((ord) => { return ord.id == order.id})

    if(idx > -1) {
      Object.assign(state.orders[idx], order)
    }
  },
  [types.ORDER_CALLING] (state, {order_id}) {
    const idx = state.orders.findIndex((ord) => { return ord.id == order_id})

    if(idx > -1) {
      state.orders[idx].transport_status = 'calling'
      state.orders[idx].transport_called_at = new Date()
    }
  },
  [types.ORDER_TRANSPORTER] (state, {order_id}) {
    const idx = state.orders.findIndex((ord) => { return ord.id == order_id})

    if(idx > -1) {
      state.orders[idx]
    }
  },
  [types.ORDER_CALL_EMPTY] (state, order_id) {
    const idx = state.orders.findIndex((ord) => { return ord.id == order_id})

    if(idx > -1) {
      state.orders[idx].transport_status = 'call_empty'
    }
  },
  [types.ORDER_NOT_FOUND] (state, order_id) {
  },
  [types.ORDER_CALL_ERRORS] (state, order_id) {
  },
  [types.RESET_ORDER_CALL] (state, order_id) {
    const idx = state.orders.findIndex((ord) => { return ord.id == order_id})

    if(idx > -1) {
      state.orders[idx].transport_status = null
    }
  },
  [types.REMOVE_ORDER_CALLS] (state, order_id) {
    const idx = state.orders.findIndex((ord) => { return ord.id == order_id})

    if(idx > -1) {
      Object.assign(state.orders[idx], {order_calls: [], transport_status: null})
    }
  }
}


export default {
  state,
  mutations
}
