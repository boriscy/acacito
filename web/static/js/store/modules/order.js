import types from '../mutation-types'

// initial state
const state = {
  orders: [],
  order: {}
}

const setOrder = (order) => {
  return Object.assign(order, getTransportStatus(order), {viewStatus: ''})
}

const getTransportStatus = (order) => {
  let obj = {}

  if(order.trans && order.trans.transporter_id) {
    obj = {transport_status: 'responded', responded_at: order.trans.responded_at}
  } else if(order.order_calls.length > 0) {
    obj = {transport_status: 'calling', responded_at: null}
  } else {
    obj = {transport_status: null, responded_at: null}
  }

  return obj
}

const mutations = {
  [types.FETCH_ORDERS] (state, {orders}) {

    state.orders = orders.map(ord => { return setOrder(ord) })
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
      const o = Object.assign(order, getTransportStatus(order))
      Object.assign(state.orders[idx], o)
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
  },
  [types.ORDER_LOADING] (state, {val, order_id}) {
    const idx = state.orders.findIndex((ord) => { return ord.id == order_id})

    if(idx > -1) {
      Object.assign(state.orders[idx], {loading: val})
    }
  },
  [types.ORDER_VIEW_STATUS] (state, {order, viewStatus}) {
    const idx = state.orders.findIndex((ord) => { return ord.id == order.id})

    if(idx > -1) {
      Object.assign(state.orders[idx], {viewStatus})
    }
  }
}


export default {
  state,
  mutations
}
