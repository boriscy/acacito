<template>
  <div class="tag-container" v-bind:class="tagActiveClass">
    <ul class="dropdown-menu w100" v-bind:style="{display: openSuggestion ? 'block' : ''}">
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

Taggle.prototype._setInputWidth = function(width) {
  if(width) {
    width = width - 10
  }
  this.input.style.width = (width || 10) + 'px'
}

export default {
  mixins: [translate],
  data() {
    return {
      open: false,
      current: 0,
      tag: null,
      selection: '',
      input: null,
      tagActiveClass: '',
      parentTagsName: null
    }
  },
  props: {
    suggestions: {
      type: Array
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
      let values = this.tag ? this.tag.tag.values : []

      return this.suggestions
      .filter((str) => { return values.indexOf(str) == -1 })
      .slice(0, 10).filter((str) => {
        return str.indexOf(this.selection) >= 0
      })
    },
    openSuggestion() {
      return this.selection !== '' &&
        this.matches.length > 0 &&
        this.open === true
    }
  },
  methods: {
    enter() {
      this.selection = this.matches[this.current]
      this.tag.add([this.selection])
      this.open = false
    },
    up() {
      if(this.current > 0)
        this.current--;
    },
    down() {
      if(this.current < this.suggestions.length - 1)
        this.current++
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
    },
    //Events for input autocomplete
    setInputEvents() {
      this.input = this.tag.getInput()
      this.input.placeholder = this.gettext("Enter tags")
      this.input.tabIndex = 0
      setTimeout(() => {
        document.querySelector('.taggle_input').focus()
      }, 2000)

      this.input.onblur = (e) => {
        this.tagActiveClass = ''
        this.open = false
        return e
      }
      this.input.focus = (e) => {
        this.tagActiveClass = 'active'
        return e
      }

      const that = this
      this.input.onkeyup = function(event) {
        switch (event.keyCode) {
          // enter
          case 13:
            event.preventDefault()
            that.enter()
          break
          // up
          case 38:
            event.preventDefault()
            that.up()
          break
          // down
          case 40:
            event.preventDefault()
            that.down()
          break
          default:
            that.change()
        }
      }
      this.input.keydown = function(event) {
        switch (event.keyCode) {
          case 38:
            event.preventDefault()
        }
      }
    }
  },
  mounted() {
    const that = this
    if(this.pname) {
      setTimeout(() => {
        this.parentOb = this.getParent(this.pname)
      }, 100)
    }
    this.tags = this.selection || []
    setTimeout(() => {
      this.tag = new Taggle(this.$el, {
        hiddenInputName: this.inputName,
        tags: this.selected || [],
        clearOnBlur: false,
        focusInputOnContainerClick: true,
        submitKeys: [188],
        onTagAdd: (e, tag) => {
          if(that.pname) {
            console.log(that.parentOb);
            that.tags.push(tag)
            that.parentOb[that.parentTagsName] = that.tags
          }
        }
      })

      this.setInputEvents()
    }, 50)
  }
}
</script>
