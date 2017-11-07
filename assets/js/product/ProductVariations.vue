<script>
import { format } from '../mixins'

export default {
  mixins: [format],
  props: {
    product: {
      type: Object,
      required: true
    }
  },
  methods: {
    productName (field, idx) {
      return `product[variations][${idx}][${field}]`
    },
    addLine() {
      this.product.variations.push({name: '', price: 0.0})
    },
    removeLine (prod, index) {
      this.product.variations.splice(index, 1)
    },
    getPlaceholder (index) {
      let ph = [this.$t('Small'), this.$t('Medium'), this.$t('Big')][index]

      return ph ? ph : ""
    },
    roundPrice (prod) {
      prod.price = this.toFixed(+prod.price, 2)
    }
  }
}
</script>

<template>
  <div>
    <div class="prouct-variations">
      <div class="title">{{$t('Variations')}}</div>

      <div class="flex">
        <label class="name header">{{ $t('Variation name') }}</label>
        <label class="price header">{{ $t('Price') }}</label>
      </div>

      <div class="flex" v-for="(prodVar, index) in product.variations">
        <input type="hidden" v-bind:value="prodVar.id" v-bind:name="productName('id', index)"/>

        <div class="name col">
          <input type="text" v-model="prodVar.name" :name="productName('name', index)"
            class="form-control" :class="hasError(prodVar, 'name')"  :placeholder="getPlaceholder(index)"/>
          <span class="help-block">{{readError(prodVar, 'name')}}</span>
        </div>
        <div class="price col">
          <input type="number" v-model="prodVar.price" :name="productName('price', index)"
          class="form-control" :class="hasError(prodVar, 'price')" step="0.01" @blur="roundPrice(prodVar)" placeholder="0.00"/>
          <span class="error">{{ readError(prodVar, 'price') }}</span>
        </div>
        <div class="col remove">
          <button class="btn btn-danger btn-sm remove" @click.prevent="removeLine(prodVar, index)" v-show="index != 0" :title="$t('Remove')">
            <i class="material-icons">delete</i>
          </button>
        </div>
      </div>
      <button class="btn btn-primary btn-sm" @click.prevent="addLine()">{{ $t('Add line') }}</button>
    </div>
  </div>
</template>
