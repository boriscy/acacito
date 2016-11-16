<template>
  <div>
    <div class="form-group flex" v-for="(prodVar, index) in variations">
      <div v-bind:class="hasError(prodVar, 'name')">
        <input type="text" v-bind:value="prodVar.name" v-bind:name="productName('name', index)" class="form-control" v-bind:placeholder="gettext('Name')"/>
        <span class="help-block">{{readError(prodVar, 'name')}}</span>
      </div>
      <div  v-bind:class="hasError(prodVar, 'name')">
        <input type="number" v-bind:value="prodVar.price" v-bind:name="productName('price', index)" class="form-control"/>
        <span class="help-block">{{readError(prodVar, 'price')}}</span>
      </div>

      <button class="btn btn-danger btn-sm" @click.prevent="removeLine(prodVar, index)" v-show="index != 0">Remove</button>
    </div>
    <button class="btn btn-primary" @click.prevent="addLine()">Add line</button>
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
    }
  },
  mounted: function() {
    this.variations = window.productVariations
  }
}
</script>
