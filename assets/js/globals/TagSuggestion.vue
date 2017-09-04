<script>
import Tag from './TagInput.vue'

export default {
  components: {
    Tag
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
    separator: {
      type: String,
      default: ','
    },
    maxTags: {
      default: 10
    }
  },
  methods: {
    addTag(tag) {
      this.$refs.tag.addSelTag(tag)
    }
  }
}
</script>

<template>
  <div>
    <Tag :suggestions="suggestions" :selectedTags="selectedTags" pname="pname"
      :inputName="inputName" ref="tag" :maxTags="maxTags" />

    <ul class="tag-suggestions">
      <li v-for="tag in suggestions" @click="addTag(tag)">{{tag}}</li>
    </ul>
  </div>
</template>
