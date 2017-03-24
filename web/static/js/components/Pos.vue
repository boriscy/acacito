<template>
  <div>
    latitude:
    <input v-model="pos.lat" type="number"/>
    longitude:
    <input v-model="pos.lng" type="number"/>
    <button class="btn btn-primary" @click.prevent="updatePosition()">Update position</button>

    <div id="map"></div>
  </div>
</template>

<script>
import auth from '../store/api/auth'

export default {
  data() {
    return {
      pos: {lat: 1, lng: 2},
      count: 1,
      showSaved: false
    }
  },
  methods: {
    updateCoords() {
      navigator.geolocation.getCurrentPosition(this.setPosition, this.error, geoOptions);
    },
    getPositionData(position) {
    },
    //
    updatePosition(position) {
      const that = this

    },
    //
    posSuccess: function(position) {
      if(this.count > 10) {
      } else {
        this.coords = {lat: position.coords.latitude, lng: position.coords.longitude};
        var p = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
        this.marker.setPosition(p);
        this.marker.setMap(window.map);
        window.map.setCenter(p);
        this.count ++;
      }
      //this.setPosition()
    },
    posError: function() {},
    //
    setMap: function() {
    }
  },
  mounted() {
    let lng = window.pos.coordinates[0]
    let lat = window.pos.coordinates[1]
    if(window.pos.coordinates[0]) {
      try {
        this.pos.lng = window.pos.coordinates[0]
        this.pos.lat = window.pos.coordinates[1]
      }
      catch(e) {}
    }
    this.setMap()
  }
}
</script>
