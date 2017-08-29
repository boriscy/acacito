//import OrgData from './Show.vue'
import OrgImage from './Image.vue'

document.addEventListener('loadOrgEdit', () => {

  new Vue({
    el: '.vue',
    components: {
      OrgImage
    },
    data() {
      return {
        images: []
      }
    },
    methods: {
      addLine() {
        this.images.push({})
      }
    },
    mounted() {
      this.images = window.organization.images
    }
  })
})
