<template>
  <div>
    <button class="btn btn-primary btn-sm" @click="togglePublishButtonText()" v-if="showButton">
      {{togglePublishText | translate}}
    </button>
    <button class="btn btn-primary btn-sm" @click="preview()" v-if="showButton">
      {{'Preview' | translate}}
    </button>
    <br/><br/>

    <div class="flex">
      <div class="product-list">
        <div class="product pointer" v-for="product in products" v-on:click="showProduct(product)">
          <div class="price">
              {{product.variations[0].price | price}}
              <small>{{org.currency | currency}}</small>
              <i class="material-icons" v-if="product.variations.length>1" size="0.9rem" :title="$t('more variations')">add_circle</i>
          </div>

          <div class="published" :class="{active: product.published}" v-on:click.stop="publish(product)" v-if="showPublish">
            {{product.published ? $t('published') : $t('unpublished')}}
          </div>

          <div class="product-image">
            <figure>
              <img :src="product.image_thumb" :ref="`img${product.id}`"/>
            </figure>
          </div>
          <div class="name">{{product.name}}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ProductsList',
  data () {
    return {
      togglePublishText: 'Hide publish',
      showPublish: true,
      org: window.org,
      products: window.products,
      prevWin: null
    }
  },
  computed: {
    showButton () { return !window.location.search.match(/preview/) }
  },
  methods: {
    showProduct (prod) {
      if (!this.showButton) {
        return
      }
      window.location = `/products/${prod.id}`
    },
    //
    togglePublishButtonText () {
      if (this.showPublish) {
        this.togglePublishText = 'Show publish'
      } else {
        this.togglePublishText = 'Hide publish'
      }
      this.showPublish = !this.showPublish
    },
    //
    publish (prod) {
      console.log('prod', prod);
    },
    //
    preview () {
      if (this.prevWin) {
        this.prevWin.close()
      }
      this.prevWin = window.open('/products?preview=true', 'parent', 'width=300,height=600')
    }
  },
  mounted () {
    if (!this.showButton) {
      document.querySelector('.top-menu').style.display = 'none'
      document.querySelector('.main-title .tit').style.display = 'none'
      document.querySelector('.main-title .actions').style.display = 'none'
      this.showPublish = false
    }
  }
}
</script>
