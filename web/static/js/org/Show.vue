<template>
  <div class="org-data">
    <Pos :pos="org.pos" ref="pos" />

    <div class="flex">
      <div>
        <label>Nombre</label>
        <h2>
          <input v-model="org.name"/>
        </h2>
        <span class="error">
          {{this.errors.name}}
        </span>

        <div>
          <label>Numero movil</label>
          <input v-model="org.mobile_number"/>
          <span class="error">
            {{this.errors.mobile_number}}
          </span>
        </div>

        <div>
          <label>Direccion</label>
          <textarea v-model="org.address" cols="50" rows="4">
          </textarea>
          <span class="error">
            {{this.errors.address}}
          </span>
        </div>
        <div>
          <textarea v-model="org.description" cols="50" rows="7">
          </textarea>
        </div>
      </div>
      <div class="well well-sm" style="background:white">
        <div>
          <h2>{{org.name}}</h2>
        </div>
        <div v-html="addressMD">
        </div>
        <div v-html="descriptionMD">
        </div>

      </div>
    </div>
    <button class="btn btn-primary" @click="update()" :disabled="saving">{{gettext("Update data and position")}}</button>
    <span v-if="saving">
      {{gettext("Saving")}}
    </span>
  </div>
</template>

<script>
import Pos from '../components/Pos.vue'
import {translate, format} from '../mixins'
import axios from 'axios'

const xhr = axios.create({
  headers: {
    'x-csrf-token': document.querySelector('[name=csrf]').content
  }
})

export default {
  name: 'OrgData',
  components: { Pos },
  mixins: [translate, format],
  data() {
    return {
      org: {},
      status: '',
      errors: {},
      saving: false
    }
  },
  computed: {
    addressMD() { return  this.md(this.org.address) },
    descriptionMD() { return  this.md(this.org.description) },
  },
  methods: {
    getData() {
      const pos = this.$refs.pos
      return {
        name: this.org.name,
        address: this.org.address,
        description: this.org.description,
        mobile_number: this.org.mobile_number,
        pos: {coordinates: [pos.lng, pos.lat], type: 'Point'}
      }
    },
    update() {
      this.errors = {}
      this.saving = true

      xhr.put('/organizations/current', {organization: this.getData(), format: 'json'})
      .then((resp) => {
        this.saving = false
      })
      .catch((resp) => {
        this.saving = false
        if(resp.response.data.errors) {
          this.errors = resp.response.data.errors
        }
      })
      //this.status = 'editing'
    }
  },
  mounted() {
    this.org = window.orgData
  }
}
</script>
