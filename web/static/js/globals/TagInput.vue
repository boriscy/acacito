<template>
  <div class="v-tags"tabindex="0" @focus="activate()">

    <input type="text" ref="input" :placeholder="$t('Hit enter to add tag')"
      @keydown.enter.prevent="" @keyup.prevent="addRemoveTag($event)"/>

    <a @click="addTag()">Add</a>

    <ul class="tags" :class="contActiveClass" >
      <li class="tag" v-for="(tag, idx) in form.tags" :class="{selected: tag.selected}">
        {{tag.tag}}
        <input type="hidden" :name="inputName" :value="tag.tag" />
        <span class="remove" @click="remove(tag, idx)">×</span>
      </li>
    </ul>

  </div>
</template>

<script>
export default {
  data() {
    return {
      form: {tags: []},
    }
  },
  props: {
    suggestions: {
      type: Array,
      default: []
    },
    selectedTags: {
      type: Array,
      default: () => {return []}
    },
    inputName: {
      type: String,
      default: 'tags[]'
    },
    pname: {
      type: String
    },
    tagMinLength: {
      type: Number,
      default: 2
    },
    maxTags: {
      default: 10
    }
  },
  methods: {
    activate() {
      this.$refs.input.focus()
    },
    remove(tag, idx) {
      this.form.tags.splice(idx, 1)
    },
    //
    addRemoveTag(event) {
      if(13 == event.keyCode) {
        this.addTag()
      }
      const l = this.form.tags.length

      if(8 === event.keyCode) {
        if(this.form.tags[l - 1].selected) {
          this.form.tags.pop()
        }
        this.form.tags[l - 1].selected = true
      } else {
        this.form.tags[l - 1].selected = false
      }
    },
    //
    addTag() {
      const tag = this.$refs.input.value.trim()
      .toLowerCase().replace(this.separatorRegexp, '')

      if(this.validTag(tag)) {
        this.form.tags.push({tag: tag, selected: false})
        this.$refs.input.value = ''
      }
      return false
    },
    //
    addSelTag(tag) {
      if(this.validTag(tag)) {
        this.form.tags.push({tag: tag, selected: false})
      }
    },
    //
    validTag(tag) {
      return !this.form.tags.find(v => { return tag === v.tag }) &&
       tag.length >= this.tagMinLength && this.form.tags.length < this.maxTags
    },
    //
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
        this.form.tags = this.selectedTags.map(v => { return {selected: false, tag: v} })
      })
    }
  }
}
</script>
