<template>
  <div class="v-tags"tabindex="0" @focus="activate()">
    <ul class="tags" :class="contActiveClass" >
      <li class="tag" v-for="(tag, idx) in selected" :class="{selected: selectedTag == tag}">
        {{tag}}
        <input type="hidden" :name="inputName" :value="tag" />
        <span class="remove" @click="remove(tag, idx)">x</span>
      </li>
      <li>
        <input v-model="input" class="tag-input" ref="input"
        @focus="focus()" @blur="blur()"
        @keydown.up.prevent="up()" @keydown.down.prevent="down()"
        @keyup.enter.prevent="enter()" @keyup.delete="back()"/>
      </li>
    </ul>

    <ul class="dropdown-menu w100" :style="{display: (inputFocus && matches.length) ? 'block' : 'none'}">
      <li v-for="(suggestion, index) in matches"
          v-bind:class="{'active': isActive(index)}"
          @mousedown="selectTag(index)"
        >
        <a href="#">{{ suggestion }}</a>
      </li>
    </ul>

  </div>
</template>

<script>
import {translate} from '../mixins'

export default {
  mixins: [translate],
  data() {
    return {
      open: false,
      current: 0,
      tag: null,
      selection: '',
      inputFocus: false,
      input: '',
      contActiveClass: '',
      selectedTag: '',
      parentTagsName: null
    }
  },
  props: {
    suggestions: {
      type: Array,
      default: []
    },
    selected: {
      type: Array,
      default: () => {return []}
    },
    inputName: {
      type: String,
      default: 'tags[]'
    },
    pname: {
      type: String
    }
  },
  computed: {
    matches() {
      const txt = this.input.trim()
      if(txt == '') {
        return []
      } else {
        return this.suggestions
        .filter((str) => { return this.selected.indexOf(str) == -1 })
        .filter((str) => { return str.indexOf(this.input) > -1 })
        .slice(0, 10)
      }
    },
    openSuggestion() {
      return this.selection !== '' &&
        this.matches.length > 0 &&
        this.open === true
    }
  },
  methods: {
    activate() {
      this.$refs.input.focus()
    },
    remove(tag, idx) {
      this.selected.splice(idx, 1)
    },
    enter() {
      this.selected.push(this.matches[this.current])
      this.input = ''
    },
    up() {
      if(this.current > 0)
        this.current--;
    },
    down() {
      if(this.current < this.suggestions.length - 1)
        this.current++
    },
    back() {
      const l = this.selected.length;
      if(this.input == '' && this.selectedTag == '' && l > 0) {
        this.selectedTag = this.selected[l - 1]
      } else if(this.input == '' && l > 0) {
        console.log('remove', this.selectedTag);
      }
    },
    focus() {
      this.inputFocus = true
      this.contActiveClass = 'active'
    },
    blur() {
      this.inputFocus = false
      this.contActiveClass = ''
    },
    isActive(index) {
      return index === this.current
    },
    change() {
      this.selection = this.input.value
      if (this.open == false) {
        this.open = true
        this.current = 0
      }
    },
    focusTag() {
      this.input.focus()
    },
    selectTag(index) {
      this.selection = this.matches[index]
      this.tag.add(this.selection)
      this.open = false
    },
    getParent(path) {
      let curr = this
      let arr = path.split('.')
      this.parentTagsName = arr.pop()
      arr.forEach((v) => {
        curr = curr[v]
      })

      return curr
    }
  },
  mounted() {
    if(this.pname) {
      setTimeout(() => {
        this.parentOb = this.getParent(this.pname)
      }, 100)
    }
    this.tags = this.selection || []
  }
}
</script>
