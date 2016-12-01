export const orders = state => {
  return state.orders.all
}

export const newOrders = state => {
  return state.orders.all.filter(ord => { return ord.status == 'new' })
}

export const processOrders = state => {
  return state.orders.all.filter(ord => { return ord.status == 'process' })
}

export const transportOrders = state => {
  return state.orders.all.filter(ord => { return ord.status == 'transport' })
}

export const order = state => {
  return state.orders.one
}
