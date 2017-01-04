import types from './mutation-types'
import axios from 'axios'

///////////////////////////////////////////////////
// Orders
import orderApi from './api/order'

export const getOrders = ({commit}) => {
  orderApi.getOrders(orders => {
    commit(types.FETCH_ORDERS, {orders})
  })
}

export const getOrder = ({commit}, ord_id) => {
  orderApi.getOrder(order => {
    commit(types.FETCH_ORDER, {order})
  }, ord_id)
}

export const moveNext = ({commit}, order) => {
  orderApi.moveNext(data => {
    commit(types.UPDATE_ORDER, data)
  }, order)
}

export const addOrder = ({commit}, data) => {
  commit(types.ADD_ORDER, data)
}

//////////////////////////////////
import auth from './api/auth'

/*
 * Utility methods to make ajax requests
 */
