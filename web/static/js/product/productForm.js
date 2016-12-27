import ProductVariations from './ProductVariations.vue'
import ProductPreview from './ProductPreview.vue'
import Modal from '../globals/Modal.vue'
import Tag from '../globals/Tag.vue'

const md = new Markdown('commonmark', {html: false});

export default {
  components: {
    'product-variations': ProductVariations,
    'product-preview': ProductPreview,
    'modal': Modal,
    'tag': Tag
  },
  data() {
    return {
      form: {variations: [], name: ''},
      allTags: window.allTags,
      demoMd:
`**Esto es negrita**

*Italica*

**Items**

- Item A
- Item B

[Vinculo a google](google.com)

**Imagenes**

![Minion](https://octodex.github.com/images/minion.png)
![Stormtroopocat](https://octodex.github.com/images/stormtroopocat.jpg "The Stormtroopocat")
___
`
    }
  },
  computed: {
    demoMdHTML() { return md.render(this.demoMd) }
  },
  methods: {
    previewImage(e) {
      this.$refs.preview.previewImage(e)
    }
  },
  mounted() {
    this.form = window.product
  }
}
