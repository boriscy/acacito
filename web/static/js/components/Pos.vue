<template>
  <div class="form-inline">
    <div>
      <button class="btn btn-default" :class="getActiveCSS('selpos')" @click="selectPos()">
        <i class="material-icons">location_on</i>
        {{gettext("Click the map to select your position")}}
      </button>
      <button class="btn btn-default" :class="getActiveCSS('getpos')" @click="getPos()">
        <i class="material-icons">navigation</i>
        {{gettext("Obtain position using GPS")}}
      </button>
    </div>

    <div>
      {{gettext("Latitude")}}:
      <input v-model="lat" type="number" class="form-control pos lat input-sm"/>
      {{gettext("Longitude")}}:
      <input v-model="lng" type="number" class="form-control pos lng input-sm"/>
    </div>
  </div>
</template>

<script>
import {translate, format} from '../mixins'

let that
export default {
  name: 'Pos',
  props: {
    pos: null
  },
  watch: {
    pos:(a, b) => {
      if(a && a.coordinates) {
        that.lng = a.coordinates[0]
        that.lat = a.coordinates[1]

        that.updatePos()
      }
    }
  },
  mixins: [format, translate],
  data() {
    return {
      lat: null,
      lng: null,
      marker: null,
      posStatus: ''
    }
  },
  methods: {
    getActiveCSS(who) {
      if(who == this.posStatus) {
        return 'active'
      }
    },
    //
    updatePos() {
      if(!this.marker) {
        this.marker = L.marker([this.lat, this.lng]).addTo(window.map)
      } else {
        this.marker.setLatLng({lat: this.lat, lng: this.lng})
      }
      window.map.setView([that.lat, that.lng], 18)
    },
    //
    selectPos() {
      this.posStatus = 'selpos'
      window.map.once('click', (e) => {
        this.lat = e.latlng.lat
        this.lng = e.latlng.lng
        this.updatePos()
        this.posStatus = ''
        window.map.off('click')
      })
    },
    //
    getPos() {
      const geoOptions = {
        enableHighAccuracy: true
      }
      navigator.geolocation.getCurrentPosition(this.posSuccess, this.posError, geoOptions)
    },
    //
    posSuccess(position) {
      this.lat = position.coords.latitude
      this.lng = position.coords.longitude
      this.updatePos()
    },
    //
    posError() {},
  },
  mounted() {
    that = this
  }
}
</script>
