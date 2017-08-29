// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import 'phoenix_html'

// Set all window defaults and global methods
window.currencies = {
  "BOB": "Bs",
  "USD": "$",
}


import Vue from 'vue'
import VueRouter from 'vue-router'

window.Vue = Vue

Vue.use(VueRouter)

import moment from 'moment'

import store from './store'
import routes from './routes'

const router = new VueRouter({
  mode: 'history',
  routes
})

const path = window.location.pathname

// Mixins
import { format } from './mixins'
Vue.mixin(format)

//////////////////////////////////////
import prodForm from './product/productForm'

import edit from './organization/edit'

switch(true) {
  case window.vueLoad == 'ProductForm':
    new Vue({
      el: '.product-form',
      mixins: [prodForm]
    })
  break;
  case window.vueLoad == 'OrgData':
    new Vue({
      el: window.vueEl,
      components: {OrgData}
    })
  break;
  case !!path.match(/orders/):
    new Vue({
      store,
      router
    }).$mount('#main')
  break;
}

// set moment locale
moment.locale(window.locale)

const event = new Event('appLoaded')
document.dispatchEvent(event)
