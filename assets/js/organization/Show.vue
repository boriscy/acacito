<script>
import VPos from '../components/Pos.vue'

export default {
  name: 'OrgData',
  components: { VPos },
  data () {
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
    getData () {
      const pos = this.$refs.pos
      return {
        name: this.org.name,
        address: this.org.address,
        description: this.org.description,
        mobile_number: this.org.mobile_number,
        pos: {coordinates: [pos.lng, pos.lat], type: 'Point'}
      }
    },
    update () {
      this.errors = {}
      this.saving = true

      this.xhr.put('/organizations/current', {organization: this.getData(), format: 'json'})
        .then((resp) => {
          this.saving = false
        })
        .catch((resp) => {
          this.saving = false
          if(resp.response.data.errors) {
            this.errors = resp.response.data.errors
          }
        })
    }
  },
  mounted () {
    this.org = window.orgData
  }
}
</script>

<template>
  <div class="org-data">
    <v-pos :pos="org.pos" ref="pos" />

    <div class="flex">
      <div>
        <label>Nombre</label>
        <input v-model="org.name" class="form-control"/>
        <span class="error">
          {{this.errors.name}}
        </span>

        <div>
          <label>{{ 'Mobile number' | translate }}</label>
          <input v-model="org.mobile_number" class="form-control"/>
          <span class="error">
            {{this.errors.mobile_number}}
          </span>
        </div>

        <div>
          <label>{{ 'Address' | translate }}</label>
          <textarea v-model="org.address" cols="50" rows="4" class="form-control">
          </textarea>
          <span class="error">
            {{this.errors.address}}
          </span>
        </div>
        <div>
          <label>{{ 'Description' | translate }}</label>
          <textarea v-model="org.description" cols="50" rows="7" class="form-control">
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
    <button class="btn btn-primary" @click="update()" :disabled="saving">{{'Update data and position' | translate}}</button>
    <span v-if="saving">
      {{'Saving' | translate}}
    </span>
  </div>
</template>
