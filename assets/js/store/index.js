import Vue from 'vue'
import Vuex from 'vuex'
import vuexI18n from 'vuex-i18n'

import * as actions from './actions'
import * as getters from './getters'
import esTranslations from './translations/es'

// modules
import order from './modules/order'
import organization from './modules/organization'

Vue.use(Vuex)

const store = new Vuex.Store({
  actions,
  getters,
  modules: {
    order,
    organization,
    i18n: vuexI18n.store
  }
})

Vue.use(vuexI18n.plugin, store)

Vue.i18n.add('es', esTranslations)
//Vue.i18n.add('en', enTranslations)
Vue.i18n.set('es')

export default store
