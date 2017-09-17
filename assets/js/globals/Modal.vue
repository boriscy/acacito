<template>
  <div>
    <div class="modal" tabindex="-1" role="dialog" :class="cssClass"
     @click.self="close($event)" :style="{display: 'in' === cssClass ? 'block' : 'none'}">

      <div class="modal-dialog" role="document">
        <div class="modal-content">

          <div class="modal-header" :class="headerCSS">
            <slot name="title" class="modal-title">
            </slot>

            <button type="button" class="close" aria-label="Close" @click="close($event)">
              <span aria-hidden="true">×</span>
            </button>
          </div>

          <div class="modal-body">
            <slot name="body">

            </slot>
          </div>

          <div class="modal-footer">
            <slot name="footer">
            </slot>
          </div>

        </div>
      </div>
    </div>
    <!--<div class="modal-backdrop fade" v-if="backdrop"></div>-->
  </div>
</template>

<script>
import Transtion from 'vue'

export default {
  name: 'Modal',
  components: {
    Transtion
  },
  props: {
    closeCallback: Function,
    backdrop: {
      type: Boolean,
      default: true
    },
    headerCSS: {
      default: ''
    }
  },
  data () {
    return {
      cssClass: 'hide'
    }
  },
  methods: {
    close (event) {
      this.cssClass = ''
      setTimeout(() => {
        this.cssClass = 'hide'
        this.$emit('close')
      }, 300)
    },
    open () {
      this.cssClass = ''
      setTimeout(()=> {
        this.cssClass = 'in'
      }, 300)
    }
  }
}
</script>
