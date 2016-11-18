<template>
  <div class="prouct-variations">
    <div class="title">{{gettext("Variations")}}</div>

    <div class="flex">
      <div class="name header">{{gettext("Name")}}</div>
      <div class="price header">{{gettext("Price")}}</div>
    </div>

    <div class="flex" v-for="(prodVar, index) in variations">
      <input type="hidden" v-bind:value="prodVar.id" v-bind:name="productName('id', index)"/>

      <div v-bind:class="hasError(prodVar, 'name')" class="name col">
        <input type="text" v-model="prodVar.name"  v-bind:name="productName('name', index)"
        class="form-control" v-bind:placeholder="getPlaceholder(index)"/>
        <span class="help-block">{{readError(prodVar, 'name')}}</span>
      </div>
      <div v-bind:class="hasError(prodVar, 'price')" class="price col">
        <input type="number" v-model="prodVar.price" v-bind:name="productName('price', index)"
        class="form-control" step="0.01" @blur="roundPrice(prodVar)" placeholder="0.00"/>
        <span class="help-block">{{readError(prodVar, 'price')}}</span>
      </div>
      <div class="col remove">
        <button class="btn btn-danger btn-sm remove" @click.prevent="removeLine(prodVar, index)" v-show="index != 0">
          {{gettext("Remove")}}
        </button>
      </div>
    </div>
    <button class="btn btn-primary" @click.prevent="addLine()">{{gettext("Add line")}}</button>
  </div>
</template>

<script>
import {translate, format} from '../mixins'

export default {
  name: 'productForm',
  mixins:[translate, format],
  data: function() {
    return {
      variations: [{name: 'Test', price: 0}]
    }
  },
  methods: {
    productName: function(field, idx) {
      return `product[variations][${idx}][${field}]`
    },
    addLine: function() {
      this.variations.push({name: '', price: 0.0})
    },
    removeLine: function(prod, index) {
      this.variations.splice(index, 1)
    },
    getPlaceholder: function(index) {
      let ph = [gettext("Small"), gettext("Medium"), gettext("Big")][index]

      return ph ? ph : ""
    },
    roundPrice: function(prod) {
      prod.price = this.toFixed(+prod.price, 2)
    }
  },
  mounted: function() {
    this.variations = window.productVariations
  }
}
</script>
