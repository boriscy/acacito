<template>
  <div class="form-inline">
    <div>
      <button class="btn btn-default" :class="getActiveCSS('selpos')" @click="selectPos()">
        <i class="material-icons">location_on</i>
        {{'Click the map to select your position' | translate}}
      </button>
      <button class="btn btn-default" :class="getActiveCSS('getpos')" @click="getPos()">
        <i class="material-icons">navigation</i>
        {{'Obtain position using GPS' | translate}}
      </button>
    </div>

    <div>
      {{'Latitude' | translate}}:
      <input v-model="lat" type="number" class="form-control pos lat input-sm"/>
      {{'Longitude' | translate}}:
      <input v-model="lng" type="number" class="form-control pos lng input-sm"/>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Pos',
  props: {
    pos: null
  },
  watch: {
    pos (a, b) {
      if(a && a.coordinates) {
        this.lng = a.coordinates[0]
        this.lat = a.coordinates[1]

        this.updatePos()
      }
    }
  },
  data () {
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
      window.map.setView([this.lat, this.lng], 18)
    },
    //
    selectPos () {
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
    posSuccess (position) {
      this.lat = position.coords.latitude
      this.lng = position.coords.longitude
      this.updatePos()
    },
    //
    posError() {},
  }
}
</script>
