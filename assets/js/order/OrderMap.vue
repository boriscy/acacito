<script>
import L from 'leaflet'
import { Socket } from 'phoenix'
import { format } from '../mixins'
import { auth } from '../store/api/xhr'

let that = null
export default {
  mixins: [format],
  components: {
  },
  computed: {
    order() { return this.findOrder() || {} },
    prevUrl() { return `/private/orders/${this.$route.params.id}` }
  },
  watch: {
    order(a, b) {
      that.setMap()
      that.getPosition()
      that.loading = false
    }
  },
  data() {
    return {loading: true, transportMarker: null }
  },
  methods: {
    findOrder() {
      return this.$store.state.order.orders.find(ord => { return ord.id == this.$route.params.id })
    },
    // gets the current position for transport
    getPosition() {
      console.log(this.order);
      auth().get(`${window.apiUrl}/client_api/user_transport_position/${this.order.user_transport_id}`)
      .then((resp) => {
        this.setTransportMarker(resp.data.user)
      })
    },
    setMap() {
      let lng = this.order.client_pos.coordinates[0]
      let lat = this.order.client_pos.coordinates[1]

      this.map = L.map('map', {zoomControl: false}).setView([lat, lng], 15)
      new L.Control.Zoom({ position: 'bottomleft' }).addTo(this.map)

      L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> '
      }).addTo(this.map)

      this.setMarkers()
      //this.setTransportMarker()
    },
    setMarkers() {
      let [lng, lat] = this.order.client_pos.coordinates

      let icon = L.icon({iconUrl: 'statics/homePin.svg', iconSize: [19, 30], iconAnchor: [10, 30], popupAnchor: [0, -30]})
      L.marker([lat, lng], {icon: icon}).addTo(this.map)
      .bindPopup(`<div class="map-popup">
      <div class="title">${this.$t('My location')}</div>
      </div>
      `)

      let [lng2, lat2] = this.order.organization_pos.coordinates

      icon = L.icon({iconUrl: 'statics/pin.svg', iconSize: [19, 30], iconAnchor: [10, 30], popupAnchor: [0, -30]})
      L.marker([lat2, lng2], {icon: icon}).addTo(this.map)
      .bindPopup(`<div class="map-popup">
      <div class="title">${this.order.organization_name}</div>
      </div>
      `)
    },
    setTransportMarker(ut) {
      let [lng, lat] = ut.pos.coordinates
      if(this.transportMarker) {
        this.transportMarker.setLatLng([lat, lng])
      } else {
        const icon = L.icon({iconUrl: 'statics/carPin.svg', iconSize: [31, 31], iconAnchor: [15, 30], popupAnchor: [0, -30]})
        this.transportMarker = L.marker([lat, lng], {icon: icon}).addTo(this.map)
        .bindPopup(`<div class="map-popup">
        <div class="title">${this.order.transporter_name}</div>
        </div>
        `)
      }
    },
    setSocketChannel() {
      this.socket = new Socket(window.wsPath, {params: {token: localStorage.getItem('authToken') }})
      this.socket.connect()
      const chName = this.order.user_transport_id

      this.channel = this.socket.channel(`users:${chName}`)
      this.channel.join()
      this.channel.on('position', ut => {
        this.setTransportMarker(ut)
      })
    },
    checkStatus() {
      if('transport' !== this.order.status  || 'transporting' !== this.order.status ) {
        this.$router.replace(`/pprivate/orders/${this.$route.params.id}`)
      }
    }
  },
  mounted() {
    that = this
    if(this.order && this.order.id) {
      this.setMap()
    }
  }
}
</script>

<template>
  <div class="map-cont">
    <div id="map">
    </div>
  </div>
</template>
