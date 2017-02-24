export const orders = state => {
  return state.order.orders
}

export const newOrders = state => {
  return state.order.orders.filter(ord => { return ord.status == 'new' })
}

export const processOrders = state => {
  return state.order.orders.filter(ord => { return ord.status == 'process'  || ord.status == 'transport' })
}

export const transportOrders = state => {
  return state.order.orders.filter(ord => { return ord.status == 'transporting' })
}

export const order = state => {
  return state.order.order
}
