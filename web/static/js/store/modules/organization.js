import types from '../mutation-types'

// initial state
const state = {
  org: {}
}

const mutations = {
  [types.UPDATE_ORGANIZATION] (state, {org}) {
    state.org = org
  }
}

export default {
  state,
  mutations
}
