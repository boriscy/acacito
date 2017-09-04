//import OrgData from './Show.vue'
import OrgImage from './Image.vue'

document.addEventListener('loadOrgEdit', () => {

  new Vue({
    el: '.vue',
    components: {
      OrgImage
    },
    computed: {
      images() {
        const imgs = window.organization.images
        const listImg = this.findImg(imgs, 'list') || {ctype: 'list'}
        const logoImg = this.findImg(imgs, 'logo') || {ctype: 'logo'}

        return [listImg, logoImg]
      },
      token() { return document.querySelector('meta[name="csrf"]').content }
    },
    methods: {
      findImg(arr, ctype) {
        return arr.find( img => { return ctype === img.ctype })
      }
    },
    data() {
      return {
        saving: false
      }
    }
  })
})
