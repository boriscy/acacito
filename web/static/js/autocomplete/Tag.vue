<template>
  <div id="tags" class="tag-container" v-bind:class="tagActiveClass" style="position: relative;">
    <ul class="dropdown-menu w100" v-bind:style="{display: openSuggestion ? 'block' : ''}">
      <li v-for="(suggestion, index) in matches"
          v-bind:class="{'active': isActive(index)}"
          @click="suggestionClick($index)"
        >
        <a href="#">{{ suggestion }}</a>
      </li>
    </ul>
  </div>
</template>

<script>
Taggle.prototype._setInputWidth = function(width) {
  if(width) {
    width = width - 10
  }
  this.input.style.width = (width || 10) + 'px'
}

export default {
  data() {
    return {
      open: false,
      current: 0,
      tag: null,
      selection: '',
      input: null,
      tagActiveClass: ''
    }
  },
  props: {
    suggestions: {
      type: Array,
      required: true
    },
    selected: {
      type: Array,
      default: []
    },
    inputName: {
      type: String,
      default: 'tags[]'
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
      //console.log('open', this.selection !== '', this.matches.length > 0, this.open);
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
    suggestionClick(index) {
      this.selection = this.matches[index]
      this.open = false
    },
    //Events for input autocomplete
    setEvents() {
      this.input = this.tag.getInput()

      this.input.onblur = () => {
        this.tagActiveClass = ''
        this.open = false
      }
      this.input.focus = () => { this.tagActiveClass = 'active' }

      const that = this
      this.input.onkeyup = function(event) {
        switch (event.keyCode) {
          // enter
          case 13:
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
    setTimeout(() => {
      this.tag = new Taggle('tags', {
        hiddenInputName: this.inputName,
        tags: this.selected || [],
        clearOnBlur: false,
        submitKeys: [188]
      })
      this.setEvents()
    }, 50)
  }
}
</script>
