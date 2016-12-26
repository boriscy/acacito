<template>
  <div class="product-preview">
    <div class="title">{{product.name}}</div>
    <div class="flex">
      <div class="left">
        <img :src="imagePath" class="product-image">
      </div>
      <div class="right">
        <button v-for="variation in product.variations" class="text-center btn btn-success btn-full" @click="addProduct(product, variation)">
          <small>{{variation.name}}</small>
          <span class="price">{{getCurrency()}} {{formatNumber(variation.price)}}<span>
        </button>
      </div>
    </div>

    <div>
      <span class="tag" v-for="tag in product.tags">{{tag}}</span>
    </div>

    <div class="description">{{product.description}}</div>

  </div>

</template>

<script>
import {format} from '../mixins'

export default {
  mixins: [format],
  computed: {
    imagePath() { return this.product.image }
  },
  props:{
    product: {
      type: Object,
      required: true
    }
  },
  methods: {
    getCurrency() {
      window.organization.currency
      return 'Bs.'
    },
    previewImage(e) {
      const input = e.target
      const that = this

      if (input.files && input.files[0]) {
        var reader = new FileReader();

        reader.onload = function (e) {
          that.product.image = e.target.result;
        }
        reader.readAsDataURL(input.files[0]);
      }
    }
  }
}
</script>
