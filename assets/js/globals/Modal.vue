<template>
  <div>
    <div class="modal fade" tabindex="-1" role="dialog" :class="cssClass" :style="{display: cssClass=='in' ? 'block' : 'none'}" @click.self="close($event)">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header" :class="headerCSS">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close" @click="close($event)"><span aria-hidden="true">&times;</span></button>
            <slot name="title"></slot>
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

    <div class="modal-backdrop fade" :class="cssClass" v-if="backdrop"></div>
  </div>
</template>

<script>
export default {
  name: 'Modal',
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
  data() {
    return {
      cssClass: 'hide'
    }
  },
  methods: {
    close(event) {
      this.cssClass = ''
      setTimeout(() => {
        this.cssClass = 'hide'
        this.$emit('close')
      }, 300)
    },
    open() {
      this.cssClass = ''
      setTimeout(()=> {
        this.cssClass = 'in'
      }, 300)
    }
  }
}
</script>
