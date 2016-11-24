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
window.translations = {
  "Name": "Nombre",
  "Price": "Precio",
  "Add line": "Nueva linea",
  "Remove": "Eliminar",
  "Small": "Pequeña",
  "Medium": "Mediana",
  "Big": "Grande",
  "Variations": "Variaciones"
}
window.gettext = function(tra) {
  return translations[tra] || tra
}


import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

import moment from 'moment'

import productForm from './product/ProductForm.Comp.vue'

import store from './store'
import routes from './routes'

const router = new VueRouter({
  mode: 'history',
  routes
})

const path = window.location.pathname
console.log('v', !!path.match(/orders/));

switch(true) {
  case window.vueLoad == 'productForm':
    new Vue({
      el: '.product-variations',
      components: {
        'product-form': productForm
      }
    })
  break;
  case !!path.match(/orders/):
    new Vue({
      store,
      router
    }).$mount('#main')
  break;
}

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
