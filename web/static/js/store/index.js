import Vue from 'vue'
import Vuex from 'vuex'

import * as actions from './actions'
import * as getters from './getters'
import order from './modules/order'

Vue.use(Vuex)

const vx = new Vuex.Store({
  actions,
  getters,
  modules: {
    order
  }
})

export default vx
