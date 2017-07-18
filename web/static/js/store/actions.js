import types from './mutation-types'

///////////////////////////////////////////////////
// Orders
import orderApi from './api/order'

export const getOrders = ({commit}) => {
  orderApi.getOrders(orders => {
    commit(types.FETCH_ORDERS, {orders})
  })
}

export const getOrder = ({commit}, order_id) => {
  orderApi.getOrder(order_id, order => {
    commit(types.FETCH_ORDER, {order})
  })
}

export const moveNext = ({commit}, order) => {
  commit(types.ORDER_LOADING, {val: true, order_id: order.id})
  orderApi.moveNext(order, data => {
    commit(types.ORDER_UPDATED, data)
    commit(types.ORDER_LOADING, {val: false, order_id: order.id})
  })
}

export const moveNextConfirm = ({commit}, {order, params}) => {
  commit(types.ORDER_LOADING, {val: true, order_id: order.id})

  orderApi.moveNextConfirm({order, params}, data => {
    commit(types.ORDER_UPDATED, data)
    commit(types.ORDER_LOADING, {val: false, order_id: order.id})
  })
}

export const addOrder = ({commit}, data) => {
  commit(types.ADD_ORDER, data)
}

export const setOrderViewStatus = ({commit}, data) => {
  commit(types.ORDER_VIEW_STATUS, {order: data.order, viewStatus: data.viewStatus})
}

// Transport
export const callTransport = ({commit}, data) => {
  commit(types.ORDER_CALLING, {order_id: data.id})

  orderApi.callTransport(data.id, (data, order_id) => {
    // No transports
    if(data.status == 424 || data.status == 400) {
      commit(types.ORDER_CALL_EMPTY, data.id)
    }
    // Internal error
    if(data.status == 400) {
      commit(types.ORDER_CALL_EMPTY, data.id)
    }
    // Error
    if(data.status == 422) {
      commit(types.ORDER_CALL_ERRORS, {data: data.data, order_id: order_id})
    }
    // Not found
    if(data.status == 422) {
      commit(types.ORDER_NOT_FOUND, order_id)
    }

    //commit(types.ORDER_TRANSPORTER, {order_id: data.id})
  })
}

export const cancelCall = ({commit}, order_id) => {
  orderApi.cancelCall(order_id, (data) => {
    if(data.status == 404) {
      // TODO nor found
      commit(types.ORDER_CALL_EMPTY, order_id)
    }

    if(data.status == 200) {
      commit(types.REMOVE_ORDER_CALLS, order_id)
    }
  })
}

//////////////////////////////////
// Organization
import organizationApi from './api/organization'

export const openCloseOrganization = ({commit}) => {
  organizationApi.openCloseOrganization((data) => {
    console.log(data)
    commit(types.UPDATE_ORGANIZATION, {org: data.organization})
  })
}
