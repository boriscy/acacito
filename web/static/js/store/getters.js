export const orders = state => {
  return state.orders.all
}

export const order = state => {
  console.log('Order 1B', state);
  return state.orders.one
}
