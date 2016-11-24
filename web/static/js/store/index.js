import Vue from 'vue'
import Vuex from 'vuex'

import * as actions from './actions'
import * as getters from './getters'
import orders from './order_module'

Vue.use(Vuex)

const vx = new Vuex.Store({
  actions,
  getters,
  modules: {
    orders
  }
})

export default vx
